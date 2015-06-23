//Aplicacion de Processing/Android para el monitor cardiaco
//
//Esta simple aplicacion dibuja un grafico de electro cardiograma
//con los datos recibidos desde el modulo bluetooth. Los datos
//provienen de un arduino equipado con un monitor de ritmo cardiaco
//en formato binario (entero de 8 bits sin signo).
import java.util.*;
import ketai.ui.*;
import ketai.net.bluetooth.*;

//Objetos asociados al bluetooth
KetaiBluetooth Kbt;
ArrayList listaDisp;
String nombreDisp;

//Cantidad de lecturas a mostrar en pantalla
int numLecturas;

//Arreglo de lecturas y variable con la posicion a escribir.
//Nota: Las lecturas se guardan como coordenada vertical de la
//pantalla
int lecturas[];
int pLectura;

void setup() {
  int i;

  //Inicializa la pantalla en modo horizontal y ajusta el tamaño
  //de la ventana al de la pantalla del dispositivo Android
  orientation(LANDSCAPE);
  size(displayWidth, displayHeight);

  //Inicializa el arreglo con las lecturas
  numLecturas = 128;
  lecturas = new int[numLecturas];

  //Inicializa las clases de bluetooth y sensores
  Kbt = new KetaiBluetooth(this);

  //Obtiene la lista de dispositivos bluetooth emparejados
  listaDisp = Kbt.getPairedDeviceNames();

  //Imprime la lista en terminal
  Iterator itr = listaDisp.iterator();
  print("Dispositivos emparejados:");
  while (itr.hasNext()) {
    print(itr.next());
  }

  //Crea una nueva lista de seleccion en pantalla para que el
  //usuario elija un dispositivo bluetooth
  KetaiList klist = new KetaiList(this , listaDisp);

  //Inicializa el arreglo de lecturas de tal manera que se genere
  //una linea horizontal en el centro de la pantalla
  for (i=0; i<numLecturas; i++)
      lecturas[i] = height/2;
}

void draw() {
  int i;
  int pLecturaDib1, pLecturaDib2;
  int posX1, posX2;

  //Limpia el fondo de la pantalla
  background(0);

  //Dibuja el grafico del ECG en toda la pantalla, empleando una
  //linea verde con grosor de 5 pixeles
  stroke(0, 255, 0);
  strokeWeight(5);

  //Itera por todo el arreglo de lecturas, distribuyendo
  //uniformemente los puntos de manera horizontal, de tal forma
  //que abarquen toda la pantalla del dispositivo
  for (i=0; i<numLecturas-1; i++) {
    //Determina la posicion de la siguiente lectura a dibujar,
    //sumando la posicion de la lectura inicial con la del indice
    //del lazo, reiniciando con la primer lectura en caso de
    //exceder el tamaño del arreglo (se emplea un buffer circular)
    pLecturaDib1 = (pLectura + i) % numLecturas;
    //De manera similar, determina la posicion de la lectura que
    //le prosigue a la anterior
    pLecturaDib2 = (pLecturaDib1 + 1) % numLecturas;

    //Determina la posicion horizontal en donde inicia y termina
    //la linea que une los puntos de las lecturas
    posX1 = int(float(i) / float(numLecturas) * float(width));
    posX2 = int(float(i+1) / float(numLecturas) * float(width)); 

    //Dibuja la linea que une los puntos entre 2 lecturas, usando
    //el valor de la lectura directamente como posicion vertical
    line(posX1, lecturas[pLecturaDib1], posX2, lecturas[pLecturaDib2]);
  }
}

void onKetaiListSelection(KetaiList klist) {
  //Obtiene la cadena recien seleccionada
  nombreDisp = klist.getSelection();

  //Imprime el nombre de dispositivo en terminal
  print("Dispositivo seleccionado:");
  print(nombreDisp);

  //Efectua la conexion bluetooth al dispositivo seleccionado
  Kbt.connectToDeviceByName(nombreDisp);

  //Desaloja la lista, ya no es necesaria
  klist = null;
}

void onBluetoothDataEvent(String dispositivo, byte[] datos) {
  int i;
  int datoLeido;

  //Procesa todos los datos recibidos en este evento de bluetooth
  for (i=0; i<datos.length; i++) {
    //Toma el siguiente dato del arreglo
    datoLeido = datos[i];

    //El tipo de dato Byte viene con signo. Aca se corrige el dato
    //para que vaya de 0 a 255
    if (datoLeido < 0)
      datoLeido = 256 + datoLeido;

    //Se escala la lectura de manera que abarque el espacio
    //vertical de la pantalla
    lecturas[pLectura] = int((1.0 - (float(datoLeido) / 255.0)) * float(height));

    //Se avanza la posicion de escritura a la siguiente lectura,
    //reiniciando en caso que se exceda la ultima posicion
    //(buffer circular)
    pLectura = (pLectura+1) % numLecturas;
  }
}

