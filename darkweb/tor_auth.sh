#install dependancy
sudo apt install basez tor

#generating public and private keys in base32 format
echo "[*] Generating Public & Private Keys"
openssl genpkey -algorithm x25519 -out key.private.pem
cat key.private.pem | grep -v " PRIVATE KEY" | base64pem -d | tail --bytes=32 | base32 | sed 's/=//g' > private.key
openssl pkey -in key.private.pem -pubout | grep -v " PUBLIC KEY" | base64pem -d | tail --bytes=32 | base32 | sed 's/=//g' > public.key

public_key="public.key"
private_key="private.key"
hidden_service="/var/lib/tor/hidden_service/hostname"

echo "[*] Successfully Generated Keys"
echo -n "Public Key:" && cat $public_key
echo -n "Private Key:" && cat $private_key

#writing TOR keys to disk
echo "[*] Writing Tor Keys to Disk"
touch alice.auth && echo -n "descriptor:x25519:" >> alice.auth && cat public.key | tr -d '\n' >> alice.auth
touch alice.auth_private && sudo cat $hidden_service | cut -b -56 | tr '\n' ':' >> alice.auth_private && echo -n "descriptor:x25519:" >> alice.auth_private && cat private.key | tr -d '\n' >> alice.auth_private

#creates onion_auth dir and copies public and private keys to correct directories
#warning \cp overwrites files
echo "[*] Creating New DIR onion_auth"
echo "[*] Copying Files to TOR Directory"
sudo mkdir /var/lib/tor/onion_auth/
sudo \cp alice.auth_private /var/lib/tor/onion_auth/
sudo \cp alice.auth /var/lib/tor/hidden_service/authorized_clients/

echo "[*] Restarting TOR..."
sudo service tor restart
