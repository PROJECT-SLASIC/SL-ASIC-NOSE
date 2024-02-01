/**
 *
 * Copyright (C) 2021 Bosch Sensortec GmbH
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *
 */

/**
 * bme688_dev_kit.ino :
 * This is an example to log data using the BME688 development 
 * kit which has been designed to work with Adafruit ESP32 Feather Board
 * For more information visit :
 * https://www.bosch-sensortec.com/software-tools/software/bme688-software/
 */

#include "Arduino.h"
#include "FS.h"
#include "bme68xLibrary.h"
#include "commMux.h"
#include <SD.h>

/* Macros used in BME68x_datalogger module */
int mulProf1[10] = {40, 10, 10, 10, 10, 1, 1, 1, 1, 1};
int tempProf1[10] = {320, 200, 150, 200, 320, 320, 320, 320, 320, 320};
int counter=0;

#define ASIC_DEV_ADDR 0x72
#define ASIC_VOC1_REG_ADDR 0x40
#define ASIC_VOC2_REG_ADDR 0x44
#define ASIC_VOC3_REG_ADDR 0x48
#define ASIC_VOC4_REG_ADDR 0x4C
#define ASIC_VOC5_REG_ADDR 0x50
#define ASIC_CONTROL_REG_ADDR 0x54

#define N_KIT_SENS 1
#define SD_PIN_CS 33
#define SPI_COMM_SPEED 32000000
#define SD_MAX_FILES 5
#define PANIC_LED LED_BUILTIN
#define PANIC_DUR 1000
/* measurement duration */
#define MEAS_DUR 140
#define LOG_FILE_NAME "/BME688_Datalogger_Log.csv"

int k = 6;

/* Declaration of variables */
Bme68x bme[N_KIT_SENS];
commMux commSetup[N_KIT_SENS];
uint8_t lastMeasindex[N_KIT_SENS] = {0};
bme68xData sensorData[N_KIT_SENS] = {0};
String logHeader;
uint32_t lastLogged = 0;
float old_gas_resistance=0;
/**
 * @brief Initializes the sensor and hardware settings
 * Initializes the SD card module
 */
void setup(void) {
    Serial.begin(115200);
    /* Initiate SPI communication  */
    commMuxBegin(Wire, SPI);
    pinMode(PANIC_LED, OUTPUT);
    delay(100);
    Wire.setClock(100000);

  /* Setting SD Card */
    if (!SD.begin(SD_PIN_CS, SPI, SPI_COMM_SPEED, "/sd", SD_MAX_FILES)) {
        Serial.println("SD Card not found");
        panicLeds();
    } 
    else {
        SD.remove(LOG_FILE_NAME);
        File file = SD.open(LOG_FILE_NAME, "w");
        if (!file) {
            Serial.println("Failed to open file for writing");
            panicLeds();
        }
        /* Parameters for logging in the file */
        logHeader = "TimeStamp(ms),Sensor Index,Temperature(deg "
                    "C),Pressure(Pa),Humidity(%),Gas Resistance(ohm),Gas "
                    "Index,Meas Index,idac,Status,Gas Valid,Heater Stable";

        if (file.println(logHeader)) {
            Serial.println(logHeader);
            file.close();
        } 
        else {
            panicLeds();
        }
        logHeader = "";
    }

  /* Communication interface set for all the 8 sensors in the development kit */
    for (uint8_t i = 0; i < N_KIT_SENS; i++) {
        commSetup[i] = commMuxSetConfig(Wire, SPI, i, commSetup[i]);
        bme[i].begin(BME68X_SPI_INTF, commMuxRead, commMuxWrite, commMuxDelay, &commSetup[i]);
        if(bme[i].checkStatus()) {
            Serial.println("Initializing sensor " + String(i) + " failed with error " + bme[i].statusString());
            panicLeds();
        }
    }

  /* Setting the default heater profile configuration */
    for (uint8_t i = 0; i < N_KIT_SENS; i++) {
    bme[i].setTPH();

    /* Heater temperature in degree Celsius as per the suggested heater profile
        */
    uint16_t tempProf[10] = {320, 200, 150, 200, 320, 320, 320, 320, 320, 320};
    /* Multiplier to the shared heater duration */
    uint16_t mulProf[10] = {40, 10, 10, 10, 10, 1, 1, 1, 1, 1};
    /* Shared heating duration in milliseconds */
    uint16_t sharedHeatrDur =MEAS_DUR - bme[i].getMeasDur(BME68X_PARALLEL_MODE)/1000;

    bme[i].setHeaterProf(tempProf, mulProf, sharedHeatrDur, 10);

    /* Parallel mode of sensor operation */
    bme[i].setOpMode(BME68X_PARALLEL_MODE);
    }
}

float gas = 0;

void loop(void) 
{
  uint8_t nFieldsLeft = 0;
  int16_t indexDiff;
  bool newLogdata = false;
  /* Control loop for data acquisition - checks if the data is available */
  if ((millis() - lastLogged) >= MEAS_DUR) 
  {
    lastLogged = millis();
    for (uint8_t i = 0; i < N_KIT_SENS; i++)
    {
      if (bme[i].fetchData()) 
      {
        do 
        {
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

            if(sensorData[i].gas_index < 5  ) 
            {
              if(sensorData[i].gas_index==0)
              {
              counter++;
              }
              if(sensorData[i].gas_index==0 && counter==mulProf1[0] || sensorData[i].gas_index!=0)
              {
                counter=0;
                
                if(sensorData[i].gas_resistance != old_gas_resistance) 
                {
                  k=sensorData[i].gas_index;
                  old_gas_resistance = sensorData[i].gas_resistance;
                  logHeader += sensorData[i].gas_resistance;
                  if(4!= sensorData[i].gas_index)
                  {
                      logHeader += ";";
                  }
                  if(4== sensorData[i].gas_index)
                  {
                    logHeader += ";";
                    logHeader += sensorData[i].temperature;
                    logHeader += ";";
                    logHeader += sensorData[i].pressure;
                    logHeader += ";";
                    logHeader += sensorData[i].humidity;
                    logHeader += "\r\n";
                    
                    newLogdata = true;
                  }

                  switch (k)
                      {
                        case 0:
                        gas = 100*normalize(old_gas_resistance, 144591.92, 669718.75);
                        sendI2C_32(ASIC_DEV_ADDR, ASIC_VOC1_REG_ADDR, gas);
                        break;

                        case 1:
                        gas = 100*normalize(old_gas_resistance, 137931.03, 7706491);
                        sendI2C_32(ASIC_DEV_ADDR, ASIC_VOC2_REG_ADDR, gas);
                        break;

                        case 2:
                        gas = 100*normalize(old_gas_resistance, 78263.53, 28364424);
                        sendI2C_32(ASIC_DEV_ADDR, ASIC_VOC3_REG_ADDR, gas);
                        break;

                        case 3:
                        gas = 100*normalize(old_gas_resistance, 39384.62, 4870392.5);
                        sendI2C_32(ASIC_DEV_ADDR, ASIC_VOC4_REG_ADDR, gas);
                        break;
                        
                        case 4:
                        gas = 100*normalize(old_gas_resistance, 77201.45, 539942);
                        sendI2C_32(ASIC_DEV_ADDR, ASIC_VOC5_REG_ADDR, gas);
                        sendI2C_8(ASIC_DEV_ADDR, ASIC_CONTROL_REG_ADDR, 2);
                        break;
                      }
                }
              }
            }
          }
        }while (nFieldsLeft);
      }
    }
  }


  if (newLogdata) {
      newLogdata = false;

      digitalWrite(PANIC_LED, HIGH);
      
      appendFile(logHeader);
      logHeader = "";

      digitalWrite(PANIC_LED, LOW);
  }
}

/*!
 * @brief Configuring the sensor with digital pin 13 as
 * an output and toggles it at one second pace
 */
static void panicLeds(void) {
    while (1) {
        digitalWrite(PANIC_LED, HIGH);
        delay(PANIC_DUR);
        digitalWrite(PANIC_LED, LOW);
        delay(PANIC_DUR);
    }
}

/*!
 * @brief Writing the sensor data to the log file(csv)
 * @param sensorData
 */
static void writeFile(String sensorData) {

    File file = SD.open(LOG_FILE_NAME, FILE_WRITE);
    if (!file) {
        Serial.println("Failed to open file for writing");
        panicLeds();
    }
    if (file.print(sensorData)) {
        Serial.print(sensorData);
    } else {
        Serial.println("Write failed");
    }
    file.close();
}

/*!
 * @brief Appending the sensor data into the log file(csv)
 * @param sensorData
 */
static void appendFile(String sensorData) {
    File file = SD.open(LOG_FILE_NAME, FILE_APPEND);
    if (!file) {
        Serial.println("Failed to open file for appending");
        panicLeds();
    }
    if (file.print(sensorData)) {
        Serial.print(sensorData);
    } else {
        Serial.println("Write append");
    }
    file.close();
}

//*********************************************************************//
static void sendI2C_8(uint8_t devAddr, uint8_t regAddr, uint8_t data)
{
    Wire.beginTransmission(devAddr);
    Wire.write(regAddr);
    Wire.write(data);
    Wire.endTransmission();
}

static void sendI2C_32(uint8_t devAddr, uint8_t regAddr, float data)
{
    uint8_t i;
    uint8_t byteData;
    uint32_t longData;

    memcpy(&longData, &data, sizeof(float));

    for (i = 0; i < 4; i++) // LSB First
    {
        byteData = longData >> (8 * i);
        Wire.beginTransmission(devAddr);
        Wire.write(regAddr + i);
        Wire.write(byteData);
        Wire.endTransmission();
    }
}

float normalize(float number, float min, float max)
{
  return (number - min) / (max - min);
}
