//Monitor cardiaco para el Arduino MicroView de sparkfun
//
//Este sketch permite al microview visualizar un grafico de
//electrocardiograma generado con la señal proveniente de
//un modulo monitor cardiaco de sparkfun:
//https://www.sparkfun.com/products/12650
//
//Los datos del monitor son reducidos de resolucion a 8 bits
//y enviados de forma binaria (en formato de entero sin signo)
//a un modulo bluetooth, para su visualizacion en la aplicacion
//de Android
#include <MicroView.h>
#include <SoftwareSerial.h>

//Puerto serie por software conectado al bluetooth
SoftwareSerial serieBT(2, 3);

//Definicion de pines
int pinEntradaAnaloga = 0;
int pinLoMen = 6;
int pinLoMas = 5;

//Parametros geometricos de la pantalla
const byte anchoPantalla = 64;
const byte altoPantalla = 48;
const byte mascaraAncho = 0x3F; //Decimal 63

//Buffer circular con las lecturas
word lecturas[anchoPantalla];
//Posicion a escribir en el buffer
byte pLectura = 0;

const int adc33 = 3.3 / 5.0 * 1023;

void setup() {
  byte i;

  pinMode(pinLoMen, INPUT);
  pinMode(pinLoMas, INPUT);

  Serial.begin(9600);
  uView.begin();
  serieBT.begin(9600);

  //Inicialmente se limpia el buffer de lecturas
  for (i=0; i<anchoPantalla; i++)
    //El valor por defecto es la posicion que deberia dibujarse
    //al leerse 3.3V divididos entre 2 (1.65V), pero se resta
    //el factor de la unidad (se invierte verticalmente) dado
    //que la pantalla tiene coordenadas ascendentes hacia abajo
    lecturas[i] = (altoPantalla-1) * (1.0 - 3.3 / 5.0 / 2.0);
}

void loop() {
  byte i;
  byte pLecturaDib1, pLecturaDib2;
  int datoADC;
  int dato8bit;
  byte datoSerie;

  //Si cualquiera de las puntas se desconecta, ignorara la
  //lectura y asumira dato "cero" (en realidad tomara la
  //mitad del rango de entrada de 3.3V)
  if (digitalRead(pinLoMen) == 1 || digitalRead(pinLoMas) == 1)
    datoADC = adc33/2;
  else
    datoADC = analogRead(pinEntradaAnaloga);

  //Envia el dato via Bluetooth
  dato8bit = map(datoADC, 0, adc33, 0, 255);
  dato8bit = constrain(dato8bit, 0, 255);
  datoSerie = dato8bit;
  
  serieBT.write(datoSerie);

  Serial.write(datoSerie);

  //Toma la siguiente lectura y la mapea del rango del ADC
  //al rango vertical de la pantalla
  lecturas[pLectura] = map(datoADC, 0, 1023, altoPantalla-1, 0);
  //Restringe la lectura, en caso se salga de los confines de
  //la pantalla
  lecturas[pLectura] = constrain(lecturas[pLectura],
                                 0, altoPantalla-1);

  //Limpia el framebuffer e inicia el proceso de dibujado
  uView.clear(PAGE);
  for (i = 0; i < anchoPantalla-1; i++) {
    //Obtiene la posicion del siguiente dato de buffer. Notese
    //que se inicia desde el dato que ira despues de la posicion
    //de lectura, el cual, por ser el mas viejo, no solo sera
    //sobre escrito en la siguiente iteracion, sino que ademas
    //sirve como punto de partida para iniciar el grafico.
    pLecturaDib1 = (pLectura + 1 + i) & mascaraAncho;
    //Nota: La mascara AND permite hacer las operaciones de
    //recorte con mas eficiencia que si se usara modulo (%)

    //El dato que sigue se obtiene incrementando y recortando
    //tambien
    pLecturaDib2 = (pLecturaDib1 + 1) & mascaraAncho;

    //Se dibuja una linea entre los 2 puntos
    uView.line(i, lecturas[pLecturaDib1],
               i+1, lecturas[pLecturaDib2]);
  }

  //Imprime un mensaje en la parte superior de la pantalla
  uView.setCursor(0, 0);
  uView.print("ALSW");

  //Despliega el contenido del frame buffer
  uView.display();

  //Una vez terminado el dibujado, apunta a la siguiente
  //posicion en el buffer circular
  pLectura++;
  //La posicion del buffer reinicia si llega al final
  if (pLectura >= anchoPantalla) pLectura = 0;

  //Se temporiza la animacion
  delay(10);
}
