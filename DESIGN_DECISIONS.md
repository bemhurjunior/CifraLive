# Design Decisions — CifraLive

## 1. Formato CFL

O CifraLive terá um formato próprio chamado `.cfl`.

O objetivo é permitir que uma música completa seja compartilhada em um único arquivo.

Um `.cfl` poderá conter:

- Dados da música
- Cifra
- Playback
- Sincronização LRC
- Configurações
- Futuramente capa, observações e outros recursos

---

## 2. Uso de JSON

O JSON será usado para salvar os dados principais da música.

Motivo:

- É simples
- É leve
- É fácil de ler
- Facilita backup
- Facilita sincronização futura
- Facilita importação/exportação

---

## 3. ManifestCfl

Todo arquivo `.cfl` terá um manifesto.

O manifesto identifica:

- Formato
- Versão do formato
- Criador
- Data de criação
- ID único

---

## 4. CflPackage

O `CflPackage` representa uma música completa dentro do CifraLive.

Ele agrupa:

- Manifest
- Música
- Playback
- LRC
- Capa futura

---

## 5. Compatibilidade futura

O formato CFL deve ser criado pensando em crescimento.

Mesmo que hoje ele salve apenas alguns dados, no futuro poderá suportar:

- Repertórios
- Biblioteca online
- Loja oficial
- Backup em nuvem
- Compartilhamento entre usuários