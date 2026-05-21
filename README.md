# TileFetch

Uma aplicação mobile moderno construída com **Flutter**, oferecendo autenticação segura e interface intuitiva com tema dark customizado.

## Características

- **Autenticação** com Firebase Authentication
- **Cadastro de usuários** com validação
- **Design responsivo** para diferentes tamanhos de tela
- **Interface pixel art** com fontes customizadas (VCR OSD Mono, Pixeled)
- **Ícones vetoriais** com suporte SVG
- **Formatação automática** de telefone

## Tecnologias Utilizadas

### Backend & Autenticação
- **Firebase Authentication** - Autenticação com email/senha
- **Cloud Firestore** - Banco de dados NoSQL em tempo real
- **Firebase Core** - Inicialização do Firebase

### Frontend
- **Flutter 3.7.2+** - Framework UI cross-platform
- **Material Design 3** - Design system moderno
- **Flutter SVG** - Suporte a ícones vetoriais
- **Pixelart Icons** - Ícones pixel art

### Design & Assets
- **Fontes Customizadas**
  - VCR OSD Mono (tema retro)
  - Pixeled (estilo pixel art)
- **Imagens otimizadas** (logo, background)

## Dependências Principais

```yaml
flutter: sdk: ^3.7.2
firebase_core: ^3.1.1
firebase_auth: ^5.1.1
cloud_firestore: ^5.1.0
flutter_svg: ^2.1.1
pixelarticons: ^0.4.0
cupertino_icons: ^1.0.8
```

## Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── firebase_options.dart     # Configuração do Firebase
├── login_page.dart          # Tela de login
├── register_page.dart       # Tela de cadastro
├── home_page.dart           # Tela inicial
└── theme/
    ├── index.dart           # Exporta todos os temas
    ├── app_theme.dart       # Configuração do tema global
    ├── app_colors.dart      # Paleta de cores
    ├── app_fonts.dart       # Estilos de tipografia
    ├── app_spacing.dart     # Espaçamentos/padding
    ├── app_borders.dart     # Estilos de bordas
    ├── app_buttons.dart     # Estilos de botões
    ├── app_text_fields.dart # Estilos de campos de texto
    └── app_assets.dart      # Caminhos de assets

assets/
├── images/
│   ├── background.png       # Imagem de fundo
│   └── logo.png            # Logo da aplicação
└── icons/
    └── eye_off.svg         # Ícone de visibilidade

assets/fonts/
├── VCR_OSD_MONO_1.001.ttf  # Fonte retro
└── Pixeled.ttf             # Fonte pixel art
```

## Autenticação & Dados

### Firebase Authentication
A aplicação utiliza autenticação por email/senha através do Firebase:
- Criação de conta com validação de email
- Login com credenciais
- Tratamento de erros específicos (email já em uso, senha fraca, etc)
- Sessões automáticas gerenciadas pelo Firebase

### Cloud Firestore
Dados de usuários armazenados em Firestore:
```json
{
  "uid": "user-id",
  "nome": "Nome do Usuário",
  "email": "usuario@email.com",
  "telefone": "(11) 98765-4321",
  "createdAt": "timestamp-do-servidor"
}
```

## Páginas da Aplicação

### Login Page
- **Entrada**: Email e senha
- **Validações**:
  - Email em formato válido
  - Campos obrigatórios
  - Feedback de erros específicos (usuário não encontrado, senha incorreta)
- **Ações**: Login ou redirecionamento para cadastro

### Register Page
- **Entrada**: Nome, email, senha, telefone
- **Validações de Senha**:
  - Mínimo 8 caracteres
  - Pelo menos 1 letra maiúscula
  - Pelo menos 1 letra minúscula
  - Pelo menos 1 número
  - Pelo menos 1 caractere especial
- **Formatação**: Telefone auto-formatado `(XX) XXXXX-XXXX`
- **Ações**: Cadastro com armazenamento em Firestore

### Home Page
- Página inicial após autenticação bem-sucedida
- Placeholder

## Fluxo de Autenticação

```
App Inicia
    ↓
Firebase Inicializa
    ↓
LoginPage (Padrão)
    ├→ Login Bem-sucedido → HomePage
    └→ Cadastro → RegisterPage → HomePage
```

## Validações

### Email
- Obrigatório
- Deve conter @ e domínio válido

### Senha (Registro)
- Mínimo 8 caracteres
- 1+ maiúscula (A-Z)
- 1+ minúscula (a-z)
- 1+ número (0-9)
- 1+ caractere especial (!@#$%^&*)

### Telefone
- Apenas números
- Máximo 11 dígitos
- Formatação automática

## Troubleshooting

### Erro de Firebase não inicializado
```
Certifique-se que firebase_options.dart está configurado corretamente
e que as credenciais do Firebase estão válidas.
```

### Problema com imagens/assets
```
Execute: flutter clean && flutter pub get
Depois: flutter run
```

### Erro de dependências
```bash
flutter pub upgrade
flutter pub get
```

## Autores

**Eduardo Risso**
- GitHub: [@y1990y](https://github.com/y1990y)
- Email: edurisso07@gmail.com

**Matheus Zamariolli**
- GitHub: [@MatheusZamariolli](https://github.com/MatheusZamariolli)
- Email: mathliebana@gmail.com

**Sophia Pellizon**
- GitHub: [@sophpg](https://github.com/sophpg)
- Email: 

**Victor Leal**
- GitHub: [@VictorAffonsoLeal](https://github.com/VictorAffonsoLeal)
- Email: 
---
