# Paleta de Cores - TileFetch

**AVISO**: Este é um guia de referência. Os valores reais das cores estão em `lib/theme/app_colors.dart`. Sempre verifique lá para valores atuais.

## Localização do arquivo

**Path**: `lib/theme/app_colors.dart`

Qualquer mudança de cor deve ser feita **apenas** neste arquivo. Este markdown é apenas documentação.

## Cores Disponíveis

### Cores de Texto

```dart
AppColors.textPrimary      // Texto principal (títulos, corpo)
AppColors.textSecondary    // Texto secundário (labels, hints)
AppColors.textDisabled     // Texto desabilitado
```

**Função**: Usadas para renderizar texto em diferentes estados.

### Cores de Fundo

```dart
AppColors.background       // Fundo principal da aplicação
AppColors.fieldBackground  // Fundo de campos de entrada
AppColors.overlayDark      // Overlay escuro (semi-transparente)
```

**Função**: Usadas em containers, backgrounds e overlays.

### Cores de Borda

```dart
AppColors.borderDefault    // Borda em estado normal
AppColors.accentSuccess    // Borda em foco/sucesso
```

**Função**: Usadas em `AppBorders.*` para estilos de bordas de input.

### Cores de Status

```dart
AppColors.success          // Verde - validações positivas, destaque
AppColors.error            // Vermelho - validações negativas
AppColors.warning          // Laranja - alertas e atenção
AppColors.info             // Azul - mensagens informativos
```

**Função**: Usadas para indicar estados e feedback ao usuário.

## Matriz de Uso

| Cor | Função | Onde Usar | Exemplo |
|-----|--------|-----------|---------|
| **textPrimary** | Texto principal | Títulos, corpo de texto | Texto em botões, labels |
| **textSecondary** | Texto secundário | Hints, labels de campo | Placeholder de input |
| **textDisabled** | Texto inativo | Elementos desabilitados | Botão desabilitado |
| **background** | Fundo base | Background de página | Scaffold background |
| **fieldBackground** | Fundo de input | Campos de entrada | TextField fillColor |
| **overlayDark** | Sobreposição | Overlay em imagens | Container sobre background |
| **borderDefault** | Borda normal | Estado normal | InputBorder padrão |
| **accentSuccess** | Borda destaque | Estado focado | InputBorder focusado |
| **success** | Sucesso | Validação OK | Ícone de sucesso |
| **error** | Erro | Validação NOK | Mensagem de erro |
| **warning** | Aviso | Alertas | Ícone de aviso |
| **info** | Informação | Info | Ícone informativos |

## Exemplos de Uso

### Campo de Texto com Validação
```dart
TextFormField(
  style: TextStyle(color: AppColors.textPrimary),
  decoration: InputDecoration(
    labelStyle: TextStyle(color: AppColors.textSecondary),
    fillColor: AppColors.fieldBackground,
    errorStyle: TextStyle(color: AppColors.error),
    border: AppBorders.defaultInputBorder,
    focusedBorder: AppBorders.focusedInputBorder,
    errorBorder: AppBorders.errorInputBorder,
  ),
)
```

### Botão Padrão
```dart
TextButton(
  style: TextButton.styleFrom(
    backgroundColor: AppColors.fieldBackground,
    side: BorderSide(color: AppColors.borderDefault),
  ),
  child: Text(
    'Clique',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

### Container com Overlay
```dart
Stack(
  children: [
    Image.asset('background.png'),
    Container(color: AppColors.overlayDark),
  ],
)
```

### Mensagem de Status
```dart
Row(
  children: [
    Icon(Icons.check, color: AppColors.success),
    Text(
      'Sucesso!',
      style: TextStyle(color: AppColors.textPrimary),
    ),
  ],
)
```

## Adicionando Nova Cor

### Processo

1. **Edite** `lib/theme/app_colors.dart`
2. **Adicione** a cor na seção apropriada:
   - `text*` para cores de texto
   - `background*` para cores de fundo
   - `border*` para cores de borda
   - `success`, `error`, `warning`, `info` para status

3. **Exemplo**:
   ```dart
   // Nova cor de status
   static const Color critical = Color.fromARGB(255, 255, 0, 0);
   ```

4. **Atualize** este markdown se necessário

## Alterando Cor Existente

1. Edite o valor em `lib/theme/app_colors.dart`
2. Salve o arquivo
3. Todo o aplicativo é atualizado automaticamente

**Exemplo**:
```dart
// Antes:
static const Color accentSuccess = Color.fromARGB(255, 0, 255, 65);

// Depois:
static const Color accentSuccess = Color.fromARGB(255, 50, 200, 100);
```

## Distribuição de Cores

| Categoria | Quantidade | Cores |
|-----------|-----------|--------|
| Texto | 3 | textPrimary, textSecondary, textDisabled |
| Fundo | 3 | background, fieldBackground, overlayDark |
| Borda | 2 | borderDefault, accentSuccess |
| Status | 4 | success, error, warning, info |
| **Total** | **12** | - |

## Dicas Práticas

### Sempre Use Constantes
```dart
Evite:
color: Color.fromARGB(255, 255, 255, 255)

Use:
color: AppColors.textPrimary
```

### Importe Corretamente
```dart
import 'theme/index.dart';  // Importa tudo, incluindo cores
```

### Borras: Use os Estilos
```dart
Evite:
borderSide: BorderSide(color: AppColors.borderDefault)

Use:
border: AppBorders.defaultInputBorder
```

## Arquivos Relacionados

- `lib/theme/app_colors.dart` - **Definições reais de cores** (fonte de verdade)
- `lib/theme/app_borders.dart` - Bordas (usa cores daqui)
- `lib/theme/app_buttons.dart` - Botões (usa cores daqui)
- `lib/theme/app_text_fields.dart` - Campos (usa cores daqui)
- `lib/main.dart` - Configuração de tema Material

## Notas Importantes

1. **Nunca hardcode cores** - Sempre use `AppColors.*`
2. **A verdade está em `app_colors.dart`** - Qualquer mudança lá propaga para tudo
3. **Este markdown é referência** - Pode ficar desatualizado, sempre verifique o código
4. **Cores são constantes** - Use `const` para melhor performance
5. **Opacidade em ARGB** - Valores de 0-255, não percentual (0 = transparente, 255 = opaco)

## FAQ

**P: Como verifico o valor real de uma cor?**
R: Abra `lib/theme/app_colors.dart` e veja a definição da constante.

**P: Posso mudar cores por página?**
R: Não é recomendado. Mantenha consistência usando `AppColors.*`.

**P: Como faço overlay mais ou menos transparente?**
R: Edite o valor ARGB em `app_colors.dart`:
- Primeiro valor (0-255) = alpha/opacidade (0 = transparente, 255 = opaco)
- Exemplo: `Color.fromARGB(200, 0, 0, 0)` = 78% opaco

**P: A cor que vejo não bate com o código?**
R: Verifique `lib/main.dart` que pode ter configurações de tema Material.
