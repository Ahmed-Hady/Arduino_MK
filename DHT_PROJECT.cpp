#include "Arduino.h"
#include <LiquidCrystal.h> // load lib
#include "dht.h"
#define dht_apin A0 // Analog Pin sensor is connected to
 
dht DHT;
LiquidCrystal mlcd(7,8,9,10,11,12); // make a lcd object

void setup(){
  mlcd.begin(16,2); // to tell arduino there are 16 colunms and 2 rows
  delay(500);//Delay to let system boot
}//end "setup()"
 
void loop(){
  //Start of Program 
    DHT.read11(dht_apin);
    mlcd.setCursor(0,0);
    mlcd.print("Humidity= "); // print on the lcd Humidity =  
    mlcd.print((float)DHT.humidity);
    mlcd.print("%");
    mlcd.setCursor(0,1);
    mlcd.print("Temp= ");  // print on the lcd temp =     
    mlcd.print((float)DHT.temperature); 
    mlcd.println(" C   ");
    
    delay(5000);//Wait 5 seconds before accessing sensor again.
 
  //Fastest should be once every two seconds.
 
}// end loop() 
