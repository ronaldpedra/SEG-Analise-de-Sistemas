# Documentação do Projeto: Sistema de Gestão para Pet Shop (Fase 1 - MVP)

## I. Detalhes do Projeto

| Detalhe | Valor |
| :--- | :--- |
| **Papel Assumido** | Analista de Sistemas |
| **Cliente** | Pet Shop Au Au |
| **Fase do Projeto** | Mínimo Produto Viável (MVP) com Integridade de Dados |
| **Foco Principal** | Gestão Unificada de Clientes/Pets, Serviços/Agendamento, Estoque/Vendas e Relatórios. |

---

## II. Escopo e Requisitos

### Objetivo Principal

O objetivo desta fase é criar um sistema que unifique a gestão de serviços e a venda de produtos em uma **única transação** (nota fiscal), garantindo a precisão do estoque através de automação.

### Requisitos Funcionais (RF)

| ID | Requisito |
| :--- | :--- |
| **RF001** | Gerenciar o Cadastro de Clientes e seus Pets, incluindo dados específicos do animal (espécie, raça, observações). |
| **RF002** | Gerenciar o Cadastro de Produtos, Serviços, Fornecedores e Funcionários (responsáveis pelos serviços). |
| **RF003** | Permitir o Agendamento de Serviços, vinculando o Pet, o Serviço e o Funcionário (executor). |
| **RF004** | Registrar a Entrada de Estoque por meio de Compras e Fornecedores. |
| **RF005** | Registrar Vendas de forma unificada, consolidando Produtos e Serviços em uma só nota. |
| **RF006** | Gerar Relatórios básicos (Vendas Diárias e Serviços Mais Realizados). |

### Requisitos Não Funcionais (RNF)

| ID | Requisito |
| :--- | :--- |
| **RNF001** | **Integridade de Dados:** O banco de dados deve usar *CHECK Constraints* para garantir que preços e quantidades sejam sempre maiores que zero. |
| **RNF002** | **Automação de Estoque:** O estoque deve ser atualizado automaticamente usando *Triggers* (Gatilhos) na Entrada de Compras e na Baixa de Vendas. |

---

## III. Modelo de Dados (Estrutura e Inteligência)

A estrutura do banco de dados relacional (PetShop\_DB) é composta por 13 tabelas, 2 Views e 4 automações/restrições.

### 1. Entidades Principais (Tabelas)

| Módulo | Entidades (Tabelas) | Objetivo |
| :--- | :--- | :--- |
| **Pessoas/Pets** | `CLIENTE`, `PET`, `FUNCIONARIO`, `FORNECEDOR` | Cadastro de base de clientes, animais, pessoal interno e fornecedores. |
| **Logística** | `PRODUTO`, `SERVICO`, `COMPRA`, `ITEM_COMPRA` | Gestão de itens vendáveis, precificação e entrada de estoque. |
| **Operação** | `AGENDAMENTO` | Rastreamento de serviços futuros e em andamento. |
| **Transação** | `VENDA`, `ITEM_VENDA_PRODUTO`, `ITEM_VENDA_SERVICO` | Registro da transação financeira e composição da nota fiscal única. |

### 2. Automações e Otimizações (Inteligência de BD)

| Objeto | Função | Descrição |
| :--- | :--- | :--- |
| **TRIGGER 1** | `trg_baixa_estoque_venda` | Reduz `estoque_atual` do `PRODUTO` sempre que um `ITEM_VENDA_PRODUTO` é inserido. |
| **TRIGGER 2** | `trg_entrada_estoque_compra` | Aumenta `estoque_atual` do `PRODUTO` sempre que um `ITEM_COMPRA` é inserido. |
| **CHECK** | `chk_preco_venda_positivo` | Garante que o `preco_venda` na tabela `PRODUTO` seja sempre maior que 0. |
| **CHECK** | `chk_quantidade_vendida_positiva` | Garante que a `quantidade` vendida seja sempre maior que 0. |
| **VIEW 1** | `VIEW_VENDAS_DIARIAS` | Agrega o total de vendas por data e forma de pagamento. |
| **VIEW 2** | `VIEW_SERVICOS_POPULARES` | Conta a frequência de cada `SERVICO` concluído (vendido). |