//create new class for connect thread
private class ConnectedThread extends Thread {
  private final InputStream mmInStream;
  private final OutputStream mmOutStream;

  //creation of the connect thread
  public ConnectedThread(BluetoothSocket socket) {
    InputStream tmpIn = null;
    OutputStream tmpOut = null;

    try {
      //Create I/O streams for connection
      tmpIn = socket.getInputStream();
      tmpOut = socket.getOutputStream();
    } 
    catch (IOException e) {
    }

    mmInStream = tmpIn;
    mmOutStream = tmpOut;
  }

  public void run() {
    byte[] buffer = new byte[256];
    int bytes; 

    // Keep looping to listen for received messages
    while (true) {
      try {
        bytes = mmInStream.read(buffer);            //read bytes from input buffer
        String readMessage = new String(buffer, 0, bytes);
        // Send the obtained bytes to the UI Activity via handler
        print(readMessage);
        //bluetoothIn.obtainMessage(handlerState, bytes, -1, readMessage).sendToTarget();
      } 
      catch (IOException e) {
        break;
      }
    }
  }
  //write method
  public void write(String input) {
    byte[] msgBuffer = input.getBytes();           //converts entered String into bytes
    try {
      mmOutStream.write(msgBuffer);                //write bytes over BT connection via outstream
    } 
    catch (IOException e) {
      //if you cannot write, close the application
      //finish();
      println("error fatal finish()");
    }
  }
}