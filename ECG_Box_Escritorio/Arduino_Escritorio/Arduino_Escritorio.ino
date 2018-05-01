int LMas = 6;
int LMenos = 7;
int SCorazon = A0; //Sensor Corazon

void setup() {
  Serial.begin(9600);
  pinMode(LMas, INPUT);
  pinMode(LMenos, INPUT);
  pinMode(SCorazon, INPUT);
}

void loop() {
  if ((digitalRead(LMas) == 1)) || (digitalRead(LMenos) == 1) {
    Serial.println(1024 / 2);
  }
  else {
    Serial.print(analogRead(SCorazon));
  }
  delay(1);
}
