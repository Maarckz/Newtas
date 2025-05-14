# NewTAS Wargame

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Um ambiente de desafios de segurança web estilo OverTheWire/Natas, com 34 níveis progressivos de dificuldade.

## 📋 Recursos
- 34 tiers (níveis) isolados
- Autenticação Basic Auth por nível
- Isolamento completo entre níveis
- Geração automática de senhas
- Configuração de domínios virtuais
- Ambiente auto-contido (Ubuntu 24.04 LTS)

## 🚀 Instalação

### Pré-requisitos
- Ubuntu 24.04 LTS
- Acesso root/sudo

```bash
# Atualize o sistema
sudo apt update && sudo apt upgrade -y

# Instale dependências
sudo apt install -y git apache2 php-fpm libapache2-mod-fcgid

# Clone o repositório
git clone https://github.com/seu-usuario/newtas-wargame.git
cd newtas-wargame

# Torne o script executável
chmod +x setup_newtas.sh

# Execute o script de configuração
sudo ./setup_newtas.sh
```

## 🕹 Como Jogar
Acesse os tiers através de:
```
http://tierX.newtas.local
```
Onde `X` é o número do tier (0-33)

**Credenciais Iniciais:**  
Tier 0: `tier0:[senha gerada]`  
(Consulte `/etc/natas_pass/tier0-cleartext.txt` no servidor)

## 🏗 Estrutura do Projeto
```
/home
├── tier0/               # Diretório do Tier 0
│   └── public_html/     # Arquivos web do desafio
/etc/natas_pass/
├── tier0.htpasswd       # Hashs de autenticação
└── tier0-cleartext.txt  # Senha em texto claro
```

## 🧪 Testando a Instalação
Verifique se todos os tiers estão protegidos:
```bash
# Teste de autenticação (deve retornar 401)
curl -v http://tier5.newtas.local

# Acesso com credenciais válidas
curl -u tier5:$(sudo cat /etc/natas_pass/tier5-cleartext.txt) http://tier5.newtas.local
```

## 🔧 Troubleshooting
**Problema Comum**          | **Solução**
----------------------------|------------
Erro 403 Forbidden          | Verifique permissões em `/home/tierX/public_html`
PHP não processado          | Reinicie o PHP-FPM: `sudo systemctl restart php8.3-fpm`
Domínios não resolvidos     | Verifique `/etc/hosts` e configurações de DNS

Verifique logs detalhados em:
```bash
tail -f /var/log/apache2/tier*-error.log
```

## 🤝 Contribuição
Contribuições são bem-vindas! Siga os passos:
1. Fork o projeto
2. Crie sua branch (`git checkout -b feature/novo-recurso`)
3. Commit suas mudanças (`git commit -m 'Add novo recurso'`)
4. Push para a branch (`git push origin feature/novo-recurso`)
5. Abra um Pull Request

## 📄 Licença
Distribuído sob licença MIT. Veja `LICENSE` para mais detalhes.

## ✉ Contato
Seu Nome - [@seu_twitter](https://twitter.com/seu_perfil) - email@example.com

_Projeto inspirado no Natas (OverTheWire.org)_
```

Este README inclui:
1. Badge de licença profissional
2. Seções de instalação claras
3. Formatação para melhor legibilidade
4. Tabelas de troubleshooting
5. Instruções de contribuição
6. Compatibilidade com markdown do GitHub

Para usar:
1. Crie um arquivo `LICENSE` com o texto da licença MIT
2. Ajuste as seções de contato e URLs
3. Adicione screenshots na pasta `images/` se desejar
4. Atualize as referências ao seu usuário do GitHub

Você pode ver um exemplo visualizado aqui:  
[Markdown Preview](https://markdownlivepreview.com/)
