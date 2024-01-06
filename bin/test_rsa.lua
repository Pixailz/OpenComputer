local	rsa = require("rsa")

pub, priv = rsa.open("/bin/test_rsa.priv")

print(string.format("pub  0x%x", pub))
print(string.format("priv 0x%x", priv))

m = rsa.btol("TEST")
print("m   "..m)

c = rsa.crypt(m, pub)
c_m = rsa.decrypt(c, priv, pub)

print("c_m "..rsa.ltob(c_m))
