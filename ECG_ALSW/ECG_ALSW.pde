
import android.bluetooth.*; //bt
import android.content.*;//para ver estados 
import java.util.*;
import java.lang.Object;

BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

void setup() {

  //Confirma tener un BT
  if (mBluetoothAdapter == null) {
    print("No tinees");   // Device does not support Bluetooth
  } else {
    print("Si tienes");
  }

//Activar el BT
  if (!mBluetoothAdapter.isEnabled()) {
    Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
    startActivityForResult(enableBtIntent, 1);
  }
}

void draw() {
  background(0);
}