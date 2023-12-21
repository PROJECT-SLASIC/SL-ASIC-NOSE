/******************************************************************************
 * INCLUDES
 *****************************************************************************/
#include "Arduino.h"
#include "FS.h"
#include "bme68xLibrary.h"
#include "commMux.h"
#include <SD.h>

#include "HeaterProfile.h"

/******************************************************************************
 * DEFINITIONS
 *****************************************************************************/
#define N_KIT_SENS 8

#define MEAS_DUR 140

#define SD_PIN_CS 33
#define SD_MAX_FILES 5

#define PANIC_LED LED_BUILTIN
#define PANIC_DUR 1000

#define SPI_COMM_SPEED 32000000

#define ASIC_DEV_ADDR 0x72
#define ASIC_VOC_REG_ADDR 0x45



#define LOG_FILE_NAME "/BME688_Datalogger_Log.csv"

/******************************************************************************
 * GLOABAL VARIABLES
 *****************************************************************************/
Bme68x bme[N_KIT_SENS];
commMux commSetup[N_KIT_SENS];
uint8_t lastMeasindex[N_KIT_SENS] = {0};
bme68xData sensorData[N_KIT_SENS] = {0};
String logHeader;
uint32_t lastLogged = 0;

/******************************************************************************
 * SETUP
 *****************************************************************************/
void setup(void) 
{
  Serial.begin(115200);

  /* Initiate SPI communication  */
  commMuxBegin(Wire, SPI);
  pinMode(PANIC_LED, OUTPUT);
  delay(100);

  /* Setting SD Card */
  if (!SD.begin(SD_PIN_CS, SPI, SPI_COMM_SPEED, "/sd", SD_MAX_FILES)) 
  {
    Serial.println("ERROR: SD Card not found");
    panicLeds();
  } 
  else 
  {
    SD.remove(LOG_FILE_NAME);
    File file = SD.open(LOG_FILE_NAME, "w");
    if (!file) 
    {
      Serial.println("ERROR: Failed to open file for writing");
      panicLeds();
    }
    /* Parameters for logging in the file */
    logHeader = "TimeStamp(ms),Sensor Index,Temperature(deg "
                "C),Pressure(Pa),Humidity(%),Gas Resistance(ohm),Gas "
                "Index,Meas Index,idac,Status,Gas Valid,Heater Stable";

    if (file.println(logHeader)) 
    {
      Serial.println(logHeader);
      file.close();
    } 
    else 
    {
      Serial.println("ERROR: Write failed");
      panicLeds();
    }
    logHeader = "";
  }

  /* Communication interface set for all the 8 sensors in the development kit */
  for (uint8_t i = 0; i < N_KIT_SENS; i++)
  {
    commSetup[i] = commMuxSetConfig(Wire, SPI, i, commSetup[i]);
    bme[i].begin(BME68X_SPI_INTF, commMuxRead, commMuxWrite, commMuxDelay, &commSetup[i]);

    if(bme[i].checkStatus()) 
    {
      Serial.println("Initializing sensor " + String(i) + " failed with error " + bme[i].statusString());
      panicLeds();
    }
    else 
    {
      Serial.println("Sensor " + String(i) + " is initialized succesfully");
    }
  }

  /* Setting the default heater profile configuration */
  for (uint8_t i = 0; i < N_KIT_SENS; i++) 
  {
    bme[i].setTPH();

    /* Heater temperature in degree Celsius as per the suggested heater profile */
    uint16_t temperature[10] = HP_301_Temperature;

    /* Multiplier to the shared heater duration */
    uint16_t dutyCycle[10] = HP_301_Duty_Cycle;

    /* Shared heating duration in milliseconds */
    uint16_t sharedHeatrDur = MEAS_DUR - bme[i].getMeasDur(BME68X_PARALLEL_MODE);

    bme[i].setHeaterProf(temperature, dutyCycle, sharedHeatrDur, 10);

    /* Parallel mode of sensor operation */
    bme[i].setOpMode(BME68X_PARALLEL_MODE);
  }
}

/******************************************************************************
 * LOOP
 *****************************************************************************/
void loop(void) 
{
  uint8_t i;
  uint8_t nFieldsLeft = 0;
  uint8_t heaterProfileCounter = 0;
  int16_t indexDiff;
  bool newLogdata = false;

  /* Control loop for data acquisition - checks if the data is available */
  if ((millis() - lastLogged) >= MEAS_DUR) 
  {
    lastLogged = millis();
    for (i = 0; i < N_KIT_SENS; i++) 
    {
      heaterProfileCounter = 0;
      if (bme[i].fetchData()) 
      {
        do {
          nFieldsLeft = bme[i].getData(sensorData[i]);
          /* Check if new data is received */
          if (sensorData[i].status & BME68X_NEW_DATA_MSK) 
          {
            /* Inspect miss of data index */
            indexDiff = (int16_t)sensorData[i].meas_index - (int16_t)lastMeasindex[i];
            if (indexDiff > 1) 
            {

              Serial.println("Skip I:" + String(i) +
                             ", DIFF:" + String(indexDiff) +
                             ", MI:" + String(sensorData[i].meas_index) +
                             ", LMI:" + String(lastMeasindex[i]) +
                             ", S:" + String(sensorData[i].status, HEX));
              panicLeds();
            }
            lastMeasindex[i] = sensorData[i].meas_index;

            if (i == 1)
            {
              if (heaterProfileCounter < 5)
              {
                // Send data to ASIC through I2C bus
                sendI2C(ASIC_DEV_ADDR, ASIC_VOC_REG_ADDR, sensorData[i].gas_resistance);
                heaterProfileCounter++;
              }
            }

            // Combine data to write SD card
            logHeader += millis(); // Time Stamp (ms)
            logHeader += ",";
            logHeader += i; // Sensor Index
            logHeader += ",";
            logHeader += sensorData[i].temperature; // Temperature (Celcius)
            logHeader += ",";
            logHeader += sensorData[i].pressure; // Pressure (Pa)
            logHeader += ",";
            logHeader += sensorData[i].humidity; // Humidity (%)
            logHeader += ",";
            logHeader += sensorData[i].gas_resistance; // Gas Resistance (Ohm)
            logHeader += ",";
            logHeader += sensorData[i].gas_index; // Gas Index
            logHeader += ",";
            logHeader += sensorData[i].meas_index; // Meas Index
            logHeader += ",";
            logHeader += sensorData[i].idac; // idac
            logHeader += ",";
            logHeader += String(sensorData[i].status, HEX); // Status
            logHeader += ",";
            logHeader += sensorData[i].status & BME68X_GASM_VALID_MSK; // Gas Valid
            logHeader += ",";
            logHeader += sensorData[i].status & BME68X_HEAT_STAB_MSK; // Heater Stable
            logHeader += "\r\n";
            newLogdata = true;
          }
        } while (nFieldsLeft);
      }
    }
  }

  if (newLogdata) 
  {
    newLogdata = false;

    digitalWrite(PANIC_LED, HIGH);
    
    appendFile(logHeader);
    logHeader = "";

    digitalWrite(PANIC_LED, LOW);
  }
}


/******************************************************************************
 * FUNCTIONS
 *****************************************************************************/
/******************************************************************************
 * @brief Configuring the sensor with digital pin 13 as
 * an output and toggles it at one second pace
 */
static void panicLeds(void) 
{
  while (1) 
  {
    digitalWrite(PANIC_LED, HIGH);
    delay(PANIC_DUR);
    digitalWrite(PANIC_LED, LOW);
    delay(PANIC_DUR);
  }
}

/******************************************************************************
 * @brief Writing the sensor data to the log file(csv)
 * @param sensorData
 */
static void writeFile(String sensorData) 
{
  File file = SD.open(LOG_FILE_NAME, FILE_WRITE);
  if (!file) 
  {
    Serial.println("ERROR: Failed to open file for writing");
    panicLeds();
  }
  else
  {
    if (file.print(sensorData)) 
    {
      Serial.print(sensorData);
    } 
    else 
    {
      Serial.println("ERROR: Write failed");
    }
  }
  file.close();
}

/******************************************************************************
 * @brief Appending the sensor data into the log file(csv)
 * @param sensorData
 */
static void appendFile(String sensorData) 
{
  File file = SD.open(LOG_FILE_NAME, FILE_APPEND);
  if (!file) 
  {
    Serial.println("ERROR: Failed to open file for appending");
    panicLeds();
  }
  else
  {
    if (file.print(sensorData)) 
    {
      Serial.print(sensorData);
    } 
    else 
    {
      Serial.println("Write append");
    }
  }
  file.close();
}

/******************************************************************************
 * @brief Function for sending data to the I2C bus
 * @param devAddr 
 * @param regAddr
 * @param data
 */
static void sendI2C(uint8_t devAddr, uint8_t regAddr, float data)
{
  uint8_t i;
  uint8_t byteData;
  uint32_t longData;

  longData = (uint32_t)&data;

  for (i = 0; i < 4; i++)
  {
    byteData = longData >> (8 * i);
    Wire.beginTransmission(devAddr);
    Wire.write(regAddr + i);
    Wire.write(byteData);
    Wire.endTransmission();
  }
}

/******************************************************************************
 * @brief Function for reading data from the I2C bus
 * @param devAddr 
 * @param regAddr
 */
static float readI2C(uint8_t devAddr, uint8_t regAddr)
{
  uint8_t i;
  uint8_t byteData;
  uint32_t longData = 0x00000000;

  for (i = 0; i < 4; i++)
  {
    Wire.beginTransmission(devAddr);
    Wire.write(regAddr + i);
    Wire.endTransmission();
    Wire.requestFrom(devAddr, 1);

    byteData = Wire.read();
    longData = longData | ((uint32_t)byteData >> (8 * i));
  }

  return (float)&longData;
}