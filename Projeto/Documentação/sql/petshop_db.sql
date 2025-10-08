-- 1. CRIAÇÃO DO BANCO DE DADOS
-- CREATE DATABASE petshop_db;
-- USE petshop_db;

------------------------------------------
-- 2. CRIAÇÃO DAS TABELAS BÁSICAS (ENTIDADES)
------------------------------------------

-- Tabela de Clientes
CREATE TABLE CLIENTE (
    id_cliente INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    cpf VARCHAR(14) UNIQUE,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id_cliente AUTOINCREMENT)
);

-- Tabela de Pets (Vinculada ao Cliente)
CREATE TABLE PET (
    id_pet INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    raca VARCHAR(50),
    dt_nascimento DATE,
    observacoes TEXT,
	PRIMARY KEY(id_pet AUTOINCREMENT),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

-- Tabela de Produtos (Estoque)
CREATE TABLE PRODUTO (
    id_produto INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255),
    preco_venda DECIMAL(10, 2) NOT NULL,
    estoque_atual INT NOT NULL DEFAULT 0,
	PRIMARY KEY(id_produto AUTOINCREMENT),
	-- Garante que o preço de venda é positivo
	CONSTRAINT chk_preco_venda_positivo CHECK(preco_venda > 0)
);

-- Tabela de Serviços
CREATE TABLE SERVICO (
    id_servico INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    duracao_min INTEGER NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
	PRIMARY KEY(id_servico AUTOINCREMENT)
);

-- Tabela de Funcionários (Responsáveis pelos Serviços)
CREATE TABLE FUNCIONARIO (
    id_funcionario INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    telefone VARCHAR(15),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
	PRIMARY KEY(id_funcionario AUTOINCREMENT)
);

-- Tabela de Fornecedores
CREATE TABLE FORNECEDOR (
    id_fornecedor INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
	PRIMARY KEY(id_fornecedor AUTOINCREMENT)
);

-- Tabela de Compras (Nota de Compra)
CREATE TABLE COMPRA (
    id_compra INTEGER NOT NULL,
    id_fornecedor INTEGER NOT NULL,
    data_compra DATE NOT NULL,
    numero_nota VARCHAR(50) UNIQUE,
    valor_total DECIMAL(10, 2) NOT NULL,
	PRIMARY KEY(id_compra AUTOINCREMENT),
    FOREIGN KEY (id_fornecedor) REFERENCES FORNECEDOR(id_fornecedor)
);

-- Tabela de Itens da Compra (Detalhe da Nota)
CREATE TABLE ITEM_COMPRA (
    id_item_compra INTEGER NOT NULL,
    id_compra INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    custo_unitario DECIMAL(10, 2) NOT NULL,
	PRIMARY KEY(id_item_compra AUTOINCREMENT),
    FOREIGN KEY (id_compra) REFERENCES COMPRA(id_compra),
    FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto)
);

-- Tabela de Agendamento (Vincula Pet, Serviço e Funcionário)
CREATE TABLE AGENDAMENTO (
    id_agendamento INTEGER NOT NULL,
    id_pet INTEGER NOT NULL,
    id_servico INTEGER NOT NULL,
    id_funcionario INTEGER NOT NULL,
    data_hora DATETIME NOT NULL,
    status VARCHAR(50) NOT NULL, 
	PRIMARY KEY(id_agendamento AUTOINCREMENT),
    FOREIGN KEY (id_pet) REFERENCES PET(id_pet),
    FOREIGN KEY (id_servico) REFERENCES SERVICO(id_servico),
    FOREIGN KEY (id_funcionario) REFERENCES FUNCIONARIO(id_funcionario)
);

-- Tabela de Vendas (Transação Única)
CREATE TABLE VENDA (
    id_venda INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,
    data_hora DATETIME NOT NULL,
    total_venda DECIMAL(10, 2) NOT NULL,
    forma_pagamento VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL, 
	PRIMARY KEY(id_venda AUTOINCREMENT),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
);

-- Tabela de Itens da Venda (Produtos)
CREATE TABLE ITEM_VENDA_PRODUTO (
    id_item_produto INTEGER NOT NULL,
    id_venda INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
	PRIMARY KEY(id_item_produto AUTOINCREMENT),
    FOREIGN KEY (id_venda) REFERENCES VENDA(id_venda),
    FOREIGN KEY (id_produto) REFERENCES PRODUTO(id_produto),
	-- Garante que a quantidade vendida é positiva
	CONSTRAINT chk_quantidade_vendida_positiva CHECK(quantidade > 0)
);

-- Tabela de Itens da Venda (Serviços)
CREATE TABLE ITEM_VENDA_SERVICO (
    id_item_servico INTEGER NOT NULL,
    id_venda INTEGER NOT NULL,
    id_agendamento INTEGER UNIQUE NOT NULL, 
    preco_servico DECIMAL(10, 2) NOT NULL,
	PRIMARY KEY(id_item_servico AUTOINCREMENT),
    FOREIGN KEY (id_venda) REFERENCES VENDA(id_venda),
    FOREIGN KEY (id_agendamento) REFERENCES AGENDAMENTO(id_agendamento)
);

------------------------------------------
-- 3. AUTOMAÇÃO DE ESTOQUE (TRIGGERS)
------------------------------------------

-- Gatilho 1: Baixa automática de Estoque após a Venda
CREATE TRIGGER trg_baixa_estoque_venda
AFTER INSERT ON ITEM_VENDA_PRODUTO
FOR EACH ROW
BEGIN
    UPDATE PRODUTO
    SET estoque_atual = estoque_atual - NEW.quantidade
    WHERE id_produto = NEW.id_produto;
END;

-- Gatilho 2: Entrada automática de Estoque após a Compra
CREATE TRIGGER trg_entrada_estoque_compra
AFTER INSERT ON ITEM_COMPRA
FOR EACH ROW
BEGIN
    UPDATE PRODUTO
    SET estoque_atual = estoque_atual + NEW.quantidade
    WHERE id_produto = NEW.id_produto;
END;

------------------------------------------
-- 5. RELATÓRIOS GERENCIAIS (VIEWS)
------------------------------------------

-- View 1: Relatório de Vendas Diárias
CREATE VIEW VIEW_VENDAS_DIARIAS AS
SELECT
    DATE(v.data_hora) AS data_venda,
    v.forma_pagamento,
    SUM(v.total_venda) AS total_arrecadado,
    COUNT(v.id_venda) AS numero_transacoes
FROM
    VENDA v
WHERE
    v.status = 'Fechada'
GROUP BY
    data_venda, v.forma_pagamento
ORDER BY
    data_venda DESC, total_arrecadado DESC;

-- View 2: Relatório de Serviços Mais Realizados
CREATE VIEW VIEW_SERVICOS_POPULARES AS
SELECT
    s.nome AS nome_servico,
    COUNT(ivs.id_item_servico) AS total_realizado,
    SUM(ivs.preco_servico) AS total_arrecadado_servico
FROM
    ITEM_VENDA_SERVICO ivs
JOIN
    AGENDAMENTO a ON ivs.id_agendamento = a.id_agendamento
JOIN
    SERVICO s ON a.id_servico = s.id_servico
GROUP BY
    s.nome
ORDER BY
    total_realizado DESC;
