
import android.bluetooth.*; //librerias del BT
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.*;//para ver estados 
import java.util.UUID;
import java.util.*;
import java.lang.Object;
import android.widget.ArrayAdapter;

//Variables de UI
int Ancho;//Ancho de la pantalla
int Alto;//Alto de la pantalla
int AltoB;//Alto del boton
int AnchoB;//Ancho del boton
int BotonC = 6;//Cantidad Botones
int BotonB;//Grosor del redondiado
int PuntoI;//Punto de inico del menu para centrar
int BB;
boolean MenuE = true;
int EstadoActividad = 0;
color[] ColorB = {#FFFFFF, #FF0000, #F0A0AF, #0F0000, #0F00FF, #FF00F0};//Colores de botones del menu
color Fondo;//color de fondo


//Varialble de BT
BluetoothAdapter AdaptadorBT = BluetoothAdapter.getDefaultAdapter();
ConnectedThread mConnectedThread;
BluetoothSocket btSocket = null;
static final UUID BTMODULEUUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
// String for MAC address
static String address;
//ArrayAdapter<String> mPairedDevicesArrayAdapter;
//ArrayAdapter<String> ListaBT;
Set<BluetoothDevice> ListaBTRegistrados;

void setup() {
  orientation(LANDSCAPE);
  size(displayWidth, displayHeight);
  IniciarInterface();
  //Confirma tener un BT
  if (AdaptadorBT == null) {
    print("No tinees");   // Device does not support Bluetooth
  } else {
    print("Si tienes");
  }

  //Activar el BT
  if (!AdaptadorBT.isEnabled()) {
    print("Pedir permiso para activar BT");
    Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    startActivityForResult(enableBtIntent, 1);
  }

  /*
  //Muestra lista de BT
   ListaBTRegistrados = AdaptadorBT.getBondedDevices();
   
   //create device and set the MAC address
   BluetoothDevice BTSelecionado;
   // If there are paired devices
   if (ListaBTRegistrados.size() > 0) {
   // Loop through paired devices
   for (BluetoothDevice device : ListaBTRegistrados) {
   // Add the name and address to an array adapter to show in a ListView
   println(device.getName() + "\n" + device.getAddress());
   if (device.getName().equalsIgnoreCase("ALSWMC")) {
   println("Encontrado");
   BTSelecionado = device;//Ni idea que hacer aqui <<>>
   }
   }
   } else {
   println("no se encontro ningun BT");
   }
   
   try {
   btSocket = BTSelecionado.createRfcommSocketToServiceRecord(BTMODULEUUID);
   ;
   println("Se activo el Socket BT");
   } 
   catch (IOException e) {
   println("falla la activacion del db");
   }
   
   mConnectedThread = new ConnectedThread(btSocket);
   mConnectedThread.start();
   */
}

void draw() {

  switch(EstadoActividad) {
  case 0:
    background(Fondo);
    break;
  case 1:
    MostrarListaBT();
    break;
  default:
    EstadoActividad = 0;
    break;
  }

  if (MenuE) {
    DibujarMenu();
  }
}

void IniciarInterface() {
  Ancho = displayWidth;
  Alto = displayHeight;
  AltoB = Alto/8;
  AnchoB = Ancho/12;
  PuntoI = (Alto-AltoB*BotonC)/2;
  BB = AnchoB/4;
}

//Funcion que dibuja el menu izquierdo 
void DibujarMenu() {
  pushStyle(); 
  pushMatrix();
  translate(0, PuntoI);
  for (int i = 0; i< BotonC; i++) {
    int BS = 0;
    int BI = 0;
    if (i == 0) {
      BS = BB;
    } else if (i == BotonC -1) {
      BI = BB;
    }
    fill(ColorB[i]);
    rect(0, AltoB*i, AnchoB, AltoB, 0, BS, BI, 0);
  }
  popStyle();
  popMatrix();
}

//Opera si la pantalla es precionada
void mousePressed() {
  if (MenuE) {
    int Contador = -1;
    Contador = MenuPrecionado();
    EstadoActividad = Contador;
    if (Contador > 0) {
      Fondo = ColorB[Contador];
      if (Contador == BotonC - 1) {
        MenuE = false;
      }
    }
  } else {
  }
}

void MostrarListaBT() {
  pushStyle();
  pushMatrix();
  translate(AnchoB, AnchoB);

  fill(0);
  //textAlign(RIGHT);
  int i = 0;
  ListaBTRegistrados = AdaptadorBT.getBondedDevices();
  if (ListaBTRegistrados.size() > 0) {
    // Loop through paired devices
    for (BluetoothDevice device : ListaBTRegistrados) {
      // Add the name and address to an array adapter to show in a ListView
      println(device.getName() + "\n" + device.getAddress());
      textSize((AltoB*2)/3);
      text(device.getName(), 0, i*AltoB);
      textSize(AltoB/3);
      text("Add:"+device.getAddress(), Ancho/2, i*AltoB*(5/3));
      i++;
    }
  } else {
    println("no se encontro ningun BT");
  }
  popStyle();
  popMatrix();
}


//Funcion que encuentra que boton es precionado del menu
int MenuPrecionado() {
  println("X: " +mouseX +" Y: "+ mouseY);
  if (mouseX < AnchoB) {
    for (int i = 0; i<BotonC; i++) {
      if (mouseY>PuntoI+AltoB*i && mouseY < PuntoI+AltoB*(i+1)) {
        println("Boton "+ i);
        return i;
      }
    }
  }
  return -1;
}