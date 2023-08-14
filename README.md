# openvpn-script-mac-authenticator
Script to perform authentication via MAC ADDRESS


PT-BR
Este script serve para realizar autenticação via endereços MAC ADDRESS (6 pares hexadecimal) após a autenticação via LDAP.
Ao se conectar, será verificado se o nome do usuario existe dentro do arquivo "/etc/openvpn/macaddress.txt".
O usuario pode estar somente com o nome de usuario "felippe.abreu" (usado para administradores ou para simplesmente ignorar a autenticação) <- indicado o local onde deve ser alterado no arquivo
ou no formato "felippe.abreu-aa:aa:aa:aa:aa:aa-bb:bb:bb:bb:bb:bb" <- sem as aspas e com as letras MINUSCULAS.
Caso o usuário não exista, ou o MAC estiver errado, a autenticação será negada.

LEMBRE-SE:
No server.conf deve conter "script-security 2" e "client-connect /etc/openvpn/script_mac.sh" 
O arquivo "/etc/openvpn/macaddress.txt" contendo "nome.usuario-aa:aa:aa:aa:aa:aa-bb:bb:bb:bb:bb:bb"
Lembrar-se do "chmod +x script_mac.sh"




EN
This script serves to perform authentication via MAC ADDRESS addresses (6 hexadecimal pairs) after authentication via LDAP.
When connecting, it will be checked if the username exists inside the "/etc/openvpn/macaddress.txt" file.
The user can only have the username "felippe.abreu" (used for administrators or to simply ignore authentication) <- indicating the location where it should be changed in the file
or in the format "felippe.abreu-aa:aa:aa:aa:aa:aa-bb:bb:bb:bb:bb:bb" <- without quotation marks and with LOWERCASE letters.
If the user does not exist, or the MAC is wrong, authentication will be denied.



REMEMBER IF:
In the server.conf it should contain "script-security 2" and "client-connect /etc/openvpn/script_mac.sh"
The file "/etc/openvpn/macaddress.txt" containing "username-aa:aa:aa:aa:aa:aa-bb:bb:bb:bb:bb:bb"
Remember "chmod +x script_mac.sh"
