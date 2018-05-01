import processing.serial.*;

Serial MiPuerto;
int CantidadPuntos = 200;
int PuntosSensor[];
int Punto = 0;
void setup() {
  //Tamano de la aplicasion 

  //Opcion 1 tu pones el ancho y alto 
  size(700, 400);

  //Opcion 2 Pantalla Completa
  ///fullScreen();


  // println(Serial.list());

  //Conectarte con el Arduino

  //Opcion 1 Conectarte Escribiendo
  MiPuerto = new Serial(this, "/dev/ttyUSB0", 9600);

  //Opcion 2 Conectarte AutoMaticamente
  /* int i = 0;
   while (MiPuerto == null) {
   try {
   MiPuerto = new Serial(this, Serial.list()[i], 9600);
   print("Conectado con "+Serial.list()[i]);
   break;
   } 
   catch (Exception e) {
   // e.printStackTrace();
   }
   i++;
   if (i >= Serial.list().length ) {
   print("Error no se Encontro Arduino");
   while (true) {
   }
   }
   }
   */

  MiPuerto.bufferUntil('\n');

  PuntosSensor = new int[CantidadPuntos];
  for (int i = 0; i< CantidadPuntos; i++) {
    PuntosSensor[i] = height/2;
  }
}

void draw() { 
  background(200); 
  strokeWeight(4);
  stroke(0, 100, 0);
  
  float PAy = PuntosSensor[0];//Punto Anterior Y
  float PAx = 0;//Punto Anteriro X
  float PasosX = float(width)/CantidadPuntos;//Cantidad de pasos entre cada punto en X
  for (int i = 1; i < CantidadPuntos; i++) {
    line(PAx, PAy, PAx + PasosX, PuntosSensor[i]);
    PAy = PuntosSensor[i];
    PAx = PAx + PasosX;
    }
} 

void serialEvent(Serial p) {

  String Mensaje = p.readString();
  if (Mensaje != null) {
    Mensaje = trim(Mensaje);
    int Valor = int(Mensaje);
    PuntosSensor[Punto] = int(map(Valor, 0, 1024, 0, height));
    println("valor "+ PuntosSensor[Punto]);
    Punto++;
    if (Punto >= CantidadPuntos) {
      Punto = 0;
    }
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    saveFrame("ECG-######.png");
  }
}
