#!/usr/bin/env python
# coding: utf-8

# In[1]:


import tensorflow as tf
import pandas as pd

data = pd.read_csv('5data.csv')
data.head() 


# In[9]:


# Import necessary libraries
from keras.models import Sequential
from keras.layers import Dense
from sklearn.model_selection import train_test_split
from tensorflow.keras.initializers import RandomNormal, RandomUniform
from tensorflow.keras.initializers import GlorotNormal, GlorotUniform

# Load standardized data
data = pd.read_csv('5data.csv')
X = data[['index0','index1','index2','index3','index4']].values
y = data[['Label']].values


# In[95]:


from tensorflow.keras.models import Model
from tensorflow.keras.utils import to_categorical

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.05, random_state=30)

y_train_encoded = to_categorical(y_train, num_classes=6)
y_test_encoded = to_categorical(y_test, num_classes=6)

# Define the neural network model using Keras
model = Sequential()


# Input Layer and Hidden Layer 1
model.add(Dense(15, input_dim=5, activation='relu'))
# Hidden Layer 2
model.add(Dense(8, activation='relu'))
# Output Layer
model.add(Dense(6, activation='softmax'))

# Compile the model
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])



# Train the model
history = model.fit(X_train, y_train_encoded, epochs=200, batch_size=32, validation_data=(X_test, y_test_encoded), verbose=1)

# Evaluate the model
train_loss, train_accuracy = model.evaluate(X_train, y_train_encoded, verbose=1)
test_loss, test_accuracy = model.evaluate(X_test, y_test_encoded, verbose=1)


print(f"Training Accuracy: {train_accuracy * 100:.2f}%")
print(f"Test Accuracy: {test_accuracy * 100:.2f}%")

for layer_num, layer in enumerate(model.layers):
    weights = layer.get_weights()[0]
    biases = layer.get_weights()[1]
    
    print(f"Layer {layer_num + 1} - Weights:\n {weights}\n")
    print(f"Layer {layer_num + 1} - Biases:\n {biases}\n")
    



# In[ ]:


intermediate_layer_model = Model(inputs=model.input, outputs=model.get_layer(index=2).output)
input_data = tf.constant([[979,179,786,860]]) # Örnek girdi verisi
intermediate_output = intermediate_layer_model.predict(input_data)
print(intermediate_output)


# In[ ]:


import numpy as np
sample_input = np.array([[355,982,768,59]])  # Example input data
logits_output = model.predict(sample_input)

print(logits_output)


# In[ ]:




