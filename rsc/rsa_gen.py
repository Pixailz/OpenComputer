from Crypto.Util.number import *
import random
from pprint import pprint

KEY_LEN=16
KEY_EXPOSANT=65537

def print_bin(src):
	b = str(bin(src))
	print(" ".join([b[::-1][i:i+8] for i in range(0, len(b), 8)])[::-1])

def	byteToLong(text: str) -> int:
	number = 0
	for letter in text:
		number = (number << 8) + letter
	return number

def	longToByte(number: int) -> str:
	text = ""
	while number:
		text = chr(number & 0xff) + text
		number >>=8
	return text

def	nb_bit(number: int) -> int:
	return len(long_to_bytes(number))

def	gen_key(name: str = "id_mc_rsa"):
	while True:
		# Test message
		m = bytes_to_long(b"ABCD")
		print(f"{m = }")
		p = getPrime(KEY_LEN)
		q = getPrime(KEY_LEN)

		# Public key
		n = p * q

		# Crypt m
		c = pow(m, KEY_EXPOSANT, n)
		print(f"{c = }")

		phi = (p - 1) * (q - 1)

		try:
			# Private key
			d = inverse(KEY_EXPOSANT, phi)
		except ValueError:
			print("Cannot get private key, relaunching")
			continue

		# Cipher test message
		c_m = pow(c, d, n)

		if m != c_m:
			print("Cannot decipher m, relaunching")
			continue

		len_n = nb_bit(n)
		len_d = nb_bit(d)

		if len_n != len_d:
			print("Key len differ, relaunching")
			continue
		break

	print(f"{long_to_bytes(m)}")
	print(f"{long_to_bytes(c_m)}")
	print(f"n {n}")
	print(f"d {d}")

	with open(name + ".pub", "wb") as f:
		f.write(long_to_bytes(n))

	with open(name, "wb") as f:
		f.write(long_to_bytes(n) + long_to_bytes(d))

gen_key("Pix")
