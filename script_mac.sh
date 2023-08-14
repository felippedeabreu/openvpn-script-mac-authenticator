#!/bin/bash


#  31 - 07 - 2023 
# Felippe de Abreu - fdeabreu at live com

# versão 1.3
# duplo MAC ADDRESS
#
# Lembrando que este SCRIPT é funcional após a autenticação via LDAP
# Conexões vindas de celular foi percebido que não funciona pois MACs de celular o formato muda.

# Remembering that this SCRIPT is functional after authentication via LDAP
# Connections coming from cell phones it was noticed that it doesn't work because MACs from cell phones the format changes.

# Formato exigido do arquivo /etc/openvpn/macaddress.txt >>> felippe.abreu-aa:aa:aa:aa:aa:aa-bb:bb:bb:bb:bb:bb 
# Onde o hifen eh a separacao dos MACs, podendo conter apenas um
# ou sem o MAC depois no nome do usuario, mas nesse caso, o usuario nao tera as demais checagens do MAC - Usado para administradores.

# Required file format /etc/openvpn/macaddress.txt >>> felippe.abreu-aa:aa:aa:aa:aa:aa-bb:bb:bb:bb:bb:bb
# Where the hyphen is the separation of MACs, which may contain only one
# or without the MAC after the username, but in this case, the username will not have the other MAC checks - Used for administrators.


# Problemas que possivelmente podem ocorrer:
# Duas pessoas se conectando ao mesmo tempo talvez o script nao funcione conforme o esperado

# LEMBRE-SE:
# No server.conf deve conter "script-security 2" e "client-connect /etc/openvpn/script_mac.sh"
# Lembrar de dar chmod +x script_mac.sh

# Foi visto que conexoes vindas de celular android (dando grep no syslog -> "peer info: IV_PLAT=android" <- o MAC vem com 7 pares - nao entendi o motivo e nem pesquisei sobre.
# (MAC do celular do Vinicius > IV_HWADDR=64:66:60:62:31:62:35 e MAC do meu celular > IV_HWADDR=66:38:38:61:61:37:63)
# como no meu uso nao teremos conexoes vindas de celular, isso nao eh um problema. Mas caso queira essa autenticacao funcionando o if abaixo deve ser alterado


# REMEMBER IF:
# The server.conf should contain "script-security 2" and "client-connect /etc/openvpn/script_mac.sh"
# Remember to chmod +x script_mac.sh

# It was seen that connections were coming from an android cell phone (grep the syslog -> "peer info: IV_PLAT=android" <- the MAC comes with 7 pairs - I didn't understand the reason and didn't even research about it.
# (MAC of Vinicius' cell phone > IV_HWADDR=64:66:60:62:31:62:35 and MAC of my cell phone > IV_HWADDR=66:38:38:61:61:37:63)
# as in my use we will not have connections coming from cell phones, this is not a problem. But if you want this authentication working, the if below must be changed





data=`date "+%d-%m-%Y %H:%M:%S"`


# Pegar as ultimas 35 linhas do arquivo syslog
# Get the last 35 lines of the syslog file
syslog_lines=$(tail -n 35 /var/log/syslog | grep ovpn)


# Extrair o nome de usuario entre colchetes pois o retorno eh neste formato: "TLS: Username/Password authentication succeeded for username 'felippe.abreu' [CN SET]"
# Extract the username between square brackets because the return is in this format: "TLS: Username/Password authentication succeeded for username 'felippe.abreu' [CN SET]"
usuario_entrada=$(echo "$syslog_lines" | grep -oP 'TLS: Username/Password authentication succeeded for username\K[^[]*' | tail -n 1 | awk '{$1=$1};1')

ip=$(echo "$syslog_lines" | grep "TLS: Username/Password authentication succeeded" | awk -F ']: ' '{print $2}' | awk -F ':' '{print $1}')



# Extrair o endereço MAC (IV_HWADDR) do syslog - denominado como macaddress de entrada
# Extract MAC address (IV_HWADDR) from syslog - named as input macaddress
macaddress_entrada=$(echo "$syslog_lines" | grep -oP 'IV_HWADDR=\K.*')


# Remove os apostrofes do nome do usuario -> 'felippe.abreu' para felippe.abreu
# Remove the apostrophes from the username -> 'felippe.abreu' for felippe.abreu
usuario_entrada=$(echo $usuario_entrada | sed "s/'//g")



# O nome do usuario deve estar no arquivo "/etc/openvpn/macaddress.txt" -> Se nao estiver, ja nem executa o resto do codigo
# The username must be in the "/etc/openvpn/macaddress.txt" file -> If it isn't, it doesn't even run the rest of the code
if grep -q "^$usuario_entrada" "/etc/openvpn/macaddress.txt"; then

# Ela serve tambem para que os administradores possam instalar e se conectar de qualquer micro sem ser barrado.
# It also serves so that administrators can install and connect from any computer without being barred.

#
# IMPORTANTE: 
# O nome do usuario deve estar no arquivo "/etc/openvpn/macaddress.txt" somente com o login, com ou sem MAC Address

# IMPORTANT:
# The username must be in the "/etc/openvpn/macaddress.txt" file only with login, with or without MAC Address



# Verificar se o usuario eh "felippe.abreu" ou "vinicius.silva" e se eles estao presentes no arquivo macaddress.txt
# Alterando os nomes do usuarios aqui, nao havera a verificacao, passara direto
# Check if the user is "felippe.abreu" or "vinicius.silva" and if they are present in macaddress.txt file
# Changing the usernames here, there will be no verification, it will pass directly

  if [ "$usuario_entrada" = "felippe.abreu" ] || [ "$usuario_entrada" = "vinicius.silva" ]; then
    echo "OK - usuario especial" ; exit 0
  fi


# Verificar se o endereço MAC de entrada esta no formato correto (6 pares hexadecimais separados por dois pontos (:) -> foi visto que o padrao de entrada é dois pontos (:) 
# Verify that the input MAC address is in the correct format (6 hexadecimal pairs separated by a colon (:) -> it was seen that the input pattern is a colon (:)
  if ! echo "$macaddress_entrada" | grep -qiE '^([0-9a-f]{2}:){5}[0-9a-f]{2}$'; then
    echo "ERRO - Endereco MAC de entrada invalido" ; exit 1
  fi


 # Extrair os dois endereços MAC do arquivo macaddress.txt
 # Extract the two MAC addresses from the macaddress.txt file
  macaddress_arquivo=$(grep "^$usuario_entrada" "/etc/openvpn/macaddress.txt" | cut -d'-' -f2-)
  primeiro_mac=$(echo "$macaddress_arquivo" | cut -d'-' -f1)
  segundo_mac=$(echo "$macaddress_arquivo" | cut -d'-' -f2)
  
  # Verificar se o endereço MAC de entrada corresponde a algum dos dois endereços MAC do arquivo
  # Check if the input MAC address matches any of the two MAC addresses in the file
  if [ "$macaddress_entrada" = "$primeiro_mac" ] || [ "$macaddress_entrada" = "$segundo_mac" ]; then
    echo "OK - MAC $macaddress_entrada encontrado no arquivo para o usuario $usuario_entrada" ; exit 0
  else
    echo "ERRO - MAC ADRRESS $macaddress_entrada NAO ENCONTRADO para o usuario $usuario_entrada no arquivo" ; exit 1
  fi

else
  echo "ERRO - Usuario nao encontrado no arquivo TXT" ; exit 1
fi
