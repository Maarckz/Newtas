echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
sudo apt update -y

sudo apt install -y apache2 apache2-utils php-fpm php openssl libapache2-mod-fcgid
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/lib/dpkg/lock

sudo apt update --fix-missing
sudo apt install -y apache2 apache2-utils php-fpm php openssl libapache2-mod-fcgid
################################################





#!/bin/bash


# 2. Instalar dependências
sudo apt update && sudo apt install -y apache2 apache2-utils php-fpm php libapache2-mod-fcgid

# 3. Criar usuários e diretórios
for i in {0..33}; do
    sudo useradd -m -d "/home/tier$i" -s /bin/bash "tier$i"
    sudo mkdir -p "/home/tier$i/public_html"
    sudo chown -R "tier$i:tier$i" "/home/tier$i/public_html"
    sudo chmod 711 "/home/tier$i"
done

# 4. Configurar PHP-FPM (versão ajustável)
PHP_VER="8.3"
sudo systemctl stop php$PHP_VER-fpm

for i in {0..33}; do
    cat <<EOF | sudo tee /etc/php/$PHP_VER/fpm/pool.d/tier$i.conf >/dev/null
[tier$i]
user = tier$i
group = tier$i
listen = /run/php/php$PHP_VER-fpm-tier$i.sock
listen.owner = www-data
listen.group = www-data
pm = static
pm.max_children = 5
security.limit_extensions = .php
php_admin_flag[engine] = On
EOF
done

sudo systemctl start php$PHP_VER-fpm

# 5. Gerar senhas e configurar autenticação
sudo mkdir -p /etc/natas_pass
for i in {0..33}; do
    pass=$(openssl rand -hex 16 | cut -c1-20)
    echo "$pass" | sudo tee /etc/natas_pass/tier$i-cleartext.txt >/dev/null
    sudo htpasswd -bc /etc/natas_pass/tier$i.htpasswd "tier$i" "$pass"
    sudo chown www-data:www-data /etc/natas_pass/tier$i.*
    sudo chmod 640 /etc/natas_pass/tier$i.htpasswd
    sudo chmod 600 /etc/natas_pass/tier$i-cleartext.txt
done

# 6. Configurar Virtual Hosts (CORREÇÃO CRÍTICA)
for i in {0..33}; do
    cat <<EOF | sudo tee /etc/apache2/sites-available/tier$i.conf >/dev/null
<VirtualHost *:80>
    ServerName tier$i.newtas.local
    DocumentRoot /home/tier$i/public_html

    <Directory "/home/tier$i/public_html">
        Options -Indexes +FollowSymLinks
        AllowOverride None
        
        # Configuração de autenticação
        AuthType Basic
        AuthName "Tier $i - Restricted Access"
        AuthBasicProvider file
        AuthUserFile /etc/natas_pass/tier$i.htpasswd
        
        # Acesso restrito apenas a usuários autenticados
        <RequireAll>
            Require valid-user
        </RequireAll>
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php/php$PHP_VER-fpm-tier$i.sock|fcgi://localhost"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/tier$i-error.log
    CustomLog \${APACHE_LOG_DIR}/tier$i-access.log combined
</VirtualHost>
EOF
done

# 7. Configurar DNS local
echo -e "\n# NewTAS Wargame" | sudo tee -a /etc/hosts >/dev/null
for i in {0..33}; do
    echo "127.0.0.1 tier$i.newtas.local" | sudo tee -a /etc/hosts >/dev/null
done

# 8. Ativar módulos e sites
sudo a2enmod proxy_fcgi setenvif mpm_event
sudo a2dismod mpm_prefork
sudo a2ensite tier*.conf

# 9. Criar conteúdo para os tiers
for i in {0..33}; do
    next_tier=$((i+1))
    if [ $i -eq 33 ]; then
        content="<h1>Parabéns! Você completou todos os tiers!</h1>"
    else
        content="<h1>Tier $i</h1>
                <p>Senha do próximo tier: <a href='/tier${next_tier}_password.txt'>tier${next_tier}_password.txt</a></p>
                <p>URL do próximo tier: <a href='/next_tier.txt'>next_tier.txt</a></p>"
    fi

    cat <<EOF | sudo tee "/home/tier$i/public_html/index.php" >/dev/null
<?php
echo "$content";
?>
EOF

    # Criar arquivos de desafio
    if [ $i -lt 33 ]; then
        echo "http://tier$next_tier.newtas.local" | sudo tee "/home/tier$i/public_html/next_tier.txt" >/dev/null
        sudo cat "/etc/natas_pass/tier$next_tier-cleartext.txt" | sudo tee "/home/tier$i/public_html/tier${next_tier}_password.txt" >/dev/null
        sudo chown tier$i:tier$i "/home/tier$i/public_html/tier${next_tier}_password.txt"
        sudo chmod 600 "/home/tier$i/public_html/tier${next_tier}_password.txt"
    fi
done

# 10. Reiniciar serviços
sudo systemctl restart apache2 php$PHP_VER-fpm

# 11. Testar autenticação
echo "=== Teste Final ==="
for i in {0..33}; do
    echo -n "Tier $i: "
    status=$(curl -s -o /dev/null -w "%{http_code}" "http://tier$i.newtas.local")
    
    if [ "$status" == "401" ]; then
        echo "OK (Autenticação requerida)"
    else
        echo "ERRO: Status $status (Autenticação falhou)"
    fi
done

# 12. Teste final com senhas claras (CORREÇÃO)
echo "=== Teste Automático ==="
for i in {0..33}; do
    echo -n "Tier $i: "
    PASS=$(sudo cat "/etc/natas_pass/tier$i-cleartext.txt")
    curl -s -o /dev/null -w "%{http_code}" -u "tier$i:$PASS" "http://tier$i.newtas.local"
    echo " (sucesso se 200)"
done

echo "Configuração concluída!"








