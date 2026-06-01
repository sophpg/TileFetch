# TileFetch

Uma aplicação mobile de galeria e compartilhamento de **pixel art**, construída com **Flutter** e **Firebase**. Permite publicar, explorar e curtir criações pixel art com uma interface temática retro.

## Funcionalidades

### Feed & Exploração
- **Feed público** com carregamento paginado
- **Busca em tempo real** por título, descrição e tags
- **Filtros avançados** por cor dominante, resolução (ex: 16x16, 32x32, 64x64), tags e ordenação 
- **Grid responsivo** que adapta o número de colunas conforme a largura da tela

### Publicação
- **Upload de pixel art** da galeria do dispositivo com pré-visualização
- Processamento automático de imagem: redimensionamento, geração de thumbnail e extração de paleta de cores
- Campos de título, descrição e tags
- Limite de tamanho de ~925 KB por imagem
- Imagem armazenada como Base64 no Firestore (sem dependência de Firebase Storage)

### Interações
- **Curtidas** com atualização otimista na UI e transação no Firestore
- **Página de favoritos** listando todos os posts curtidos pelo usuário
- **Detalhe do post** em dialog com imagem em alta resolução, metadados, tags, resolução e contagem de curtidas

### Perfil
- Foto de perfil, comprimida e salva como Base64 no Firestore
- Edição de nome e bio
- Grid com todos os posts do usuário autenticado
- Logout

### Autenticação
- **Firebase Authentication** com email e senha
- Registro com validação de senha robusta (maiúscula, minúscula, número e caractere especial)
- Formatação automática de telefone no cadastro `(XX) XXXXX-XXXX`

## Tecnologias

### Backend & Serviços
- **Firebase Authentication** — autenticação email/senha
- **Cloud Firestore** — banco de dados NoSQL (posts, usuários, curtidas, histórico de busca)
- **Firebase Core** — inicialização e configuração

### Frontend
- **Flutter 3.7.2+** — framework UI cross-platform (Android e iOS)
- **flutter_svg** — suporte a ícones vetoriais
- **pixelarticons** — biblioteca de ícones estilo pixel art
- **cached_network_image** — carregamento e cache de imagens remotas
- **image_picker** — seleção de imagens da galeria e câmera
- **flutter_image_compress** — compressão de imagens antes do upload
- **palette_generator** — extração automática de cores dominantes
- **image** — decodificação e processamento de imagens

### Design & Assets
- Tema escuro customizado com paleta pixel art
- Fontes customizadas: **VCR OSD Mono** (retro) e **Pixeled** (pixel art)
- Background e logo próprios

## Dependências Principais

```yaml
environment:
  sdk: ^3.7.2

dependencies:
  firebase_core: ^3.1.1
  firebase_auth: ^5.1.1
  cloud_firestore: ^5.1.0
  firebase_storage: ^12.4.10
  flutter_svg: ^2.1.1
  pixelarticons: ^0.4.0
  cached_network_image: ^3.3.0
  image_picker: ^1.1.2
  flutter_image_compress: ^2.3.0
  palette_generator: ^0.3.2
  image: ^4.0.17
  cupertino_icons: ^1.0.8
```

## Estrutura do Projeto

```
lib/
├── main.dart                        # Ponto de entrada; inicializa Firebase e redireciona para Login ou MainNavigation
├── firebase_options.dart            # Configuração gerada pelo FlutterFire CLI
│
├── pages/
│   ├── main_navigation_page.dart    # Navegação principal com bottom nav (5 abas)
│   ├── home_page.dart               # Feed público com busca, filtros e scroll infinito
│   ├── search_page.dart             # Busca avançada com filtros e histórico
│   ├── upload_page.dart             # Formulário de publicação de pixel art
│   ├── favorites_page.dart          # Posts curtidos pelo usuário
│   ├── profile_page.dart            # Perfil, avatar, bio e posts do usuário
│   ├── login_page.dart              # Tela de login
│   └── register_page.dart           # Tela de cadastro
│
├── components/
│   ├── custom_bottom_nav.dart       # Barra de navegação inferior customizada
│   ├── search_bar.dart              # AppBar com campo de busca e histórico
│   ├── search_history_list.dart     # Lista de buscas recentes
│   ├── filter_bar.dart              # Filtros por cor, resolução, tags e ordenação
│   ├── post_card.dart               # Card de post no grid (thumbnail, curtidas)
│   └── post_detail_dialog.dart      # Dialog com detalhe completo do post
│
├── models/
│   └── post_model.dart              # Modelo Post e Resolucao com serialização Firestore
│
├── services/
│   ├── firestore_service.dart       # CRUD de posts, curtidas, perfil e histórico de busca
│   ├── upload_service.dart          # Processamento de imagem, geração de thumbnail e upload
│   └── search_history_service.dart  # Histórico de busca local em memória (singleton)
│
└── theme/
    ├── index.dart                   # Exporta todos os módulos de tema
    ├── app_theme.dart               # Configuração global do ThemeData
    ├── app_colors.dart              # Paleta de cores
    ├── app_fonts.dart               # Estilos de tipografia
    ├── app_spacing.dart             # Espaçamentos e padding
    ├── app_borders.dart             # Estilos de bordas
    ├── app_buttons.dart             # Estilos de botões
    ├── app_text_fields.dart         # Estilos de campos de texto
    ├── app_helpers.dart             # Widgets e utilitários reutilizáveis
    └── app_assets.dart              # Caminhos de assets

assets/
├── images/
│   ├── background.png               # Imagem de fundo tileada
│   └── logo.png                     # Logo da aplicação (usado também como ícone)
├── icons/
│   └── eye_off.svg                  # Ícone de visibilidade
└── fonts/
    ├── VCR_OSD_MONO_1.001.ttf       # Fonte retro
    └── Pixeled.ttf                  # Fonte pixel art
```

## Modelo de Dados (Firestore)

### Coleção `posts`
```json
{
  "authorUid": "id-do-autor",
  "titulo": "Minha Pixel Art",
  "descricao": "Descrição do post",
  "imagemBase64": "<base64>",
  "thumbnailBase64": "<base64-reduzido>",
  "imagemUrl": "",
  "thumbnail": "",
  "cores": ["#FF0000", "#00FF00"],
  "resolucao": { "largura": 32, "altura": 32 },
  "tags": ["fantasia", "personagem"],
  "curtidas": 42,
  "comentarios": 0,
  "visibilidade": "public",
  "dataCriacao": "<timestamp>",
  "dataAtualizacao": "<timestamp>"
}
```

### Coleção `users`
```json
{
  "nome": "Nome do Usuário",
  "email": "usuario@email.com",
  "telefone": "(11) 98765-4321",
  "bio": "Bio do perfil",
  "avatarBase64": "<base64>",
  "createdAt": "<timestamp>",
  "uid": "<uid>"
}
```

### Coleção `curtidas`
Documento com ID `{postId}-{userId}`:
```json
{
  "postId": "id-do-post",
  "usuarioId": "id-do-usuario",
  "dataCurtida": "<timestamp>"
}
```

## Fluxo de Navegação

```
App Inicia
    ↓
Firebase Inicializa
    ↓
Usuário autenticado? ──Não──→ LoginPage ──→ RegisterPage
    ↓ Sim                          ↓
MainNavigationPage ←───────────────┘
    ├── [0] HomePage         (feed + busca + filtros)
    ├── [1] SearchPage        (busca avançada)
    ├── [2] UploadPage        (publicar pixel art)
    ├── [3] FavoritesPage     (posts curtidos)
    └── [4] ProfilePage       (perfil + meus posts)
```

## Validações

### Senha (Registro)
- Mínimo 8 caracteres
- Pelo menos 1 letra maiúscula (A-Z)
- Pelo menos 1 letra minúscula (a-z)
- Pelo menos 1 número (0-9)
- Pelo menos 1 caractere especial (`!@#$%^&*`)

### Telefone
- Opcional
- Apenas números, máximo 11 dígitos
- Formatação automática: `(XX) XXXXX-XXXX`

### Upload de Imagem
- Tamanho máximo: ~925 KB
- Formatos suportados: qualquer formato suportado pelo `image_picker`
- Resolução detectada automaticamente

## Autores

**Eduardo Risso**
- GitHub: [@y1990y](https://github.com/y1990y)
- Email: edurisso07@gmail.com

**Matheus Zamariolli**
- GitHub: [@MatheusZamariolli](https://github.com/MatheusZamariolli)
- Email: mathliebana@gmail.com

**Sophia Pellizon**
- GitHub: [@sophpg](https://github.com/sophpg)
- Email: sophiapgouveia@gmail.com

**Victor Leal**
- GitHub: [@VictorAffonsoLeal](https://github.com/VictorAffonsoLeal)
- Email: victoraffonsoleal7@gmail.com