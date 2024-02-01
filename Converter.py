import pandas as pd
import numpy as np
import struct

def float_to_ieee754_hex(value):
    """ 
    Kayan noktalı sayıyı IEEE 754 single precision formatına dönüştür ve hexadecimal olarak döndür. 
    Eğer sayı NaN ise, dönüşüm sonucu 7fc00000 oluyorsa veya sayısal olmayan bir değerse (metin vs.), o değeri değiştirme. 
    """
    # Sayısal olmayan değerler için orijinal değeri döndür
    if not isinstance(value, (int, float)) or (isinstance(value, float) and np.isnan(value)):
        return value

    # IEEE 754 dönüşümü yap
    packed_value = struct.pack('!f', value)
    hex_value = format(struct.unpack('!I', packed_value)[0], '08x')
    
    # Eğer dönüşüm sonucu 7fc00000 ise orijinal değeri döndür
    if hex_value == "7fc00000":
        return value
    
    return hex_value

def convert_excel_and_save_new(input_file_path, output_file_path):
    # Excel dosyasını oku
    df = pd.read_excel(input_file_path)

    # Yeni bir DataFrame oluştur
    new_df = pd.DataFrame()

    # Tüm sütunları ve satırları dön
    for column in df.columns:
        new_df[column] = df[column].apply(float_to_ieee754_hex)

    # Yeni dosyaya yaz
    new_df.to_excel(output_file_path, index=False)

# Örnek kullanım
input_file_path = 'egitilecekler.xlsx'  # Girdi olarak verdiğiniz Excel dosyasının yolu
output_file_path = 'sonuc_dosyasi.xlsx'  # Çıktı olarak oluşturulacak Excel dosyasının yolu
convert_excel_and_save_new(input_file_path, output_file_path)
