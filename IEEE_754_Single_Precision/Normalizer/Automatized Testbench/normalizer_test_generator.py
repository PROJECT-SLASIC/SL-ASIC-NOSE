import numpy as np

def float_to_hex(f):
    """IEEE754 formatında bir float değeri hexadecimal string'e dönüştürür."""
    return format(np.float32(f).view('int32') & 0xFFFFFFFF, '08x')

def normalize_data(max_val, min_val, in_data):
    """Normalizasyon işlemi için örnek bir fonksiyon. IEEE754 formatında çalışır."""
    if max_val == min_val:
        return np.float32(0.0)  # Bölen 0 olmamalı
    normalized = np.float32((in_data - min_val) / (max_val - min_val))
    return normalized

def generate_test_cases(num_cases):
    test_cases = []

    for _ in range(num_cases):
        # IEEE754 formatında rastgele float değerler
        max_val = np.float32(np.random.uniform(1, 1000000))
        min_val = np.float32(np.random.uniform(0, max_val))  # min, max'den küçük olacak şekilde
        in_data = np.float32(np.random.uniform(min_val, max_val))  # in_data, min ve max arasında

        out_data = normalize_data(max_val, min_val, in_data)

        test_cases.append((
            float_to_hex(max_val),
            float_to_hex(min_val),
            float_to_hex(in_data),
            float_to_hex(out_data)
        ))

    return test_cases

def write_to_txt(test_cases, filename="normalizer_test_cases.txt"):
    with open(filename, "w") as file:
        for max_hex, min_hex, in_hex, out_hex in test_cases:
            file.write(f"{max_hex} {min_hex} {in_hex} = {out_hex}\n")

if __name__ == "__main__":
    num_cases = 10000  # 10 bin test case oluşturulacak
    test_cases = generate_test_cases(num_cases)
    write_to_txt(test_cases)
