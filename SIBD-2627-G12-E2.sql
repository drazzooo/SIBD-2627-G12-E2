/* 
Unidade Curricular: SIBD
Ano Letivo: 2026/2027
Projeto: Etapa 2
Grupo: 12

Alunos:
 - Ruan Pimentel (Nº 66502) - Turma 3
*/

DROP TABLE Pedido_Assistencia CASCADE CONSTRAINTS;
DROP TABLE Turno CASCADE CONSTRAINTS;
DROP TABLE Possui CASCADE CONSTRAINTS;
DROP TABLE Veiculo_de_Assistencia CASCADE CONSTRAINTS;
DROP TABLE Veiculo_de_Socio CASCADE CONSTRAINTS;
DROP TABLE Veiculo CASCADE CONSTRAINTS;
DROP TABLE Mecanico CASCADE CONSTRAINTS;
DROP TABLE Socio CASCADE CONSTRAINTS;
DROP TABLE Pessoa CASCADE CONSTRAINTS;
DROP TABLE Base CASCADE CONSTRAINTS;
DROP TABLE Morada CASCADE CONSTRAINTS;


CREATE TABLE Morada (
    id_morada INT,
    rua VARCHAR2(100) NOT NULL,
    num_porta INT NOT NULL,
    codigo_postal VARCHAR2(8) NOT NULL,
    localidade VARCHAR2(50) NOT NULL,
    distrito VARCHAR2(50) NOT NULL,
    
    CONSTRAINT pk_morada PRIMARY KEY (id_morada),
    CONSTRAINT ck_ria_29 CHECK (id_morada >= 1),
    CONSTRAINT ck_ria_30 CHECK (REGEXP_LIKE(codigo_postal, '^[0-9]{4}-[0-9]{3}$')),
    CONSTRAINT ck_ria_31 CHECK (num_porta > 0)
);

CREATE TABLE Base (
    codigo VARCHAR2(4),
    lugares_garagem INT NOT NULL,
    id_morada INT NOT NULL,
    
    CONSTRAINT pk_base PRIMARY KEY (codigo),
    CONSTRAINT fk_base_morada FOREIGN KEY (id_morada) REFERENCES Morada(id_morada),
    CONSTRAINT ck_ria_35 CHECK (REGEXP_LIKE(codigo, '^[a-zA-Z]{3}[0-9]$')),
    CONSTRAINT ck_ria_36 CHECK (lugares_garagem > 0)
);

CREATE TABLE Pessoa (
    NIF NUMBER(9,0),
    NIC NUMBER(8,0) NOT NULL,
    Nome VARCHAR2(100) NOT NULL,
    Nascimento DATE NOT NULL,
    Genero VARCHAR2(10) NOT NULL,
    Telemovel VARCHAR2(9) NOT NULL,
    id_morada INT NOT NULL,
      
    CONSTRAINT pk_pessoa PRIMARY KEY (NIF),
    CONSTRAINT fk_pessoa_morada FOREIGN KEY (id_morada) REFERENCES Morada(id_morada),
    CONSTRAINT uq_ria_18_nic UNIQUE (NIC), 
    CONSTRAINT uq_ria_19_telemovel UNIQUE (Telemovel), 
    CONSTRAINT ck_ria_23 CHECK (NIF BETWEEN 100000000 AND 999999999), 
    CONSTRAINT ck_ria_24 CHECK (NIC BETWEEN 1 AND 99999999), 
    CONSTRAINT ck_ria_25 CHECK (Genero IN ('Masculino','Feminino','Outro')), 
    CONSTRAINT ck_ria_26 CHECK (REGEXP_LIKE(Telemovel, '^(91|92|93|96)[0-9]{7}$')) 
);

CREATE TABLE Socio (
    NIF NUMBER(9,0),
    Numero NUMBER(6,0) NOT NULL,
      
    CONSTRAINT pk_socio PRIMARY KEY (NIF),
    CONSTRAINT fk_socio_pessoa FOREIGN KEY (NIF) REFERENCES Pessoa(NIF) ON DELETE CASCADE,
    CONSTRAINT uq_ria_20_numero UNIQUE (Numero), 
    CONSTRAINT ck_ria_27 CHECK (Numero BETWEEN 1 AND 999999) 
);

CREATE TABLE Mecanico (
    NIF NUMBER(9,0),
    num_empregado NUMBER(5,0) NOT NULL,
    codigo_base VARCHAR2(4) NOT NULL,
    
    CONSTRAINT pk_mecanico PRIMARY KEY (NIF),
    CONSTRAINT fk_mecanico_pessoa FOREIGN KEY (NIF) REFERENCES Pessoa(NIF) ON DELETE CASCADE,
    CONSTRAINT fk_mecanico_base FOREIGN KEY (codigo_base) REFERENCES Base(codigo),
    CONSTRAINT uq_ria_21_num_empregado UNIQUE (num_empregado),
    CONSTRAINT ck_ria_28 CHECK (num_empregado > 0)
);

CREATE TABLE Veiculo (
    Matricula VARCHAR2(8),
    Marca VARCHAR2(50) NOT NULL,
    Modelo VARCHAR2(50) NOT NULL,
    Tipo VARCHAR2(15) NOT NULL,
    Ano NUMBER(4,0) NOT NULL,
      
    CONSTRAINT pk_veiculo PRIMARY KEY (Matricula),
    CONSTRAINT ck_ria_33 CHECK (Tipo IN ('Automóvel','Moto')), 
    CONSTRAINT ck_ria_32 CHECK (
        REGEXP_LIKE(Matricula, '^([A-Z]{2}-[0-9]{2}-[0-9]{2}|[0-9]{2}-[0-9]{2}-[A-Z]{2}|[0-9]{2}-[A-Z]{2}-[0-9]{2}|[A-Z]{2}-[0-9]{2}-[A-Z]{2})$')
    ) 
);

CREATE TABLE Veiculo_de_Socio (
    Matricula VARCHAR2(8),
    Cor VARCHAR2(30) NOT NULL,
     
    CONSTRAINT pk_veiculo_socio PRIMARY KEY (Matricula),
    CONSTRAINT fk_veiculo_socio FOREIGN KEY (Matricula) REFERENCES Veiculo (Matricula) ON DELETE CASCADE
);

CREATE TABLE Veiculo_de_Assistencia (
    Matricula VARCHAR2(8),
    Numero NUMBER(4,0) NOT NULL,
    codigo_base VARCHAR2(4) NOT NULL,
    
    CONSTRAINT pk_veiculo_assistencia PRIMARY KEY (Matricula),
    CONSTRAINT fk_veiculo_assistencia FOREIGN KEY (Matricula) REFERENCES Veiculo (Matricula) ON DELETE CASCADE,
    CONSTRAINT fk_veic_assist_base FOREIGN KEY (codigo_base) REFERENCES Base (codigo),
    CONSTRAINT uq_ria_22_numero UNIQUE (Numero), 
    CONSTRAINT ck_ria_34 CHECK (Numero BETWEEN 1 AND 9999) 
);

CREATE TABLE Possui (
    NIF NUMBER(9,0) NOT NULL,
    Matricula VARCHAR2(8) NOT NULL,
    Desde DATE NOT NULL,
    Ate DATE,

    CONSTRAINT pk_possui PRIMARY KEY (NIF, Matricula, Desde),
    CONSTRAINT fk_possui_socio FOREIGN KEY (NIF) REFERENCES Socio(NIF),
    CONSTRAINT fk_possui_veiculo FOREIGN KEY (Matricula) REFERENCES Veiculo_de_Socio(Matricula),
    CONSTRAINT ck_ria_08 CHECK (Ate IS NULL OR Ate > Desde)
);

CREATE TABLE Turno (
    num_empregado NUMBER(5,0) NOT NULL,
    data_desde DATE NOT NULL,
    data_ate DATE,
    matricula_assistencia VARCHAR2(8) NOT NULL,
    
    CONSTRAINT pk_turno PRIMARY KEY (num_empregado, data_desde),
    CONSTRAINT fk_turno_mecanico FOREIGN KEY (num_empregado) REFERENCES Mecanico(num_empregado),
    CONSTRAINT fk_turno_veiculo FOREIGN KEY (matricula_assistencia) REFERENCES Veiculo_de_Assistencia(Matricula),
    CONSTRAINT ck_ria_10 CHECK (data_ate IS NULL OR data_ate > data_desde)
);

CREATE TABLE Pedido_Assistencia (
    NIF_socio NUMBER(9,0) NOT NULL,
    num_sequencial INT NOT NULL,
    matricula VARCHAR2(8) NOT NULL,
    data_pedido DATE NOT NULL, 
    problema VARCHAR2(255) NOT NULL,
    estado VARCHAR2(25) NOT NULL,
    morada_aproximada VARCHAR2(255),
    data_inicio DATE,
    data_conclusao DATE,
    num_empregado_turno NUMBER(5,0),
    data_desde_turno DATE,
    
    CONSTRAINT pk_pedido PRIMARY KEY (NIF_socio, num_sequencial),
    CONSTRAINT fk_pedido_socio FOREIGN KEY (NIF_socio) REFERENCES Socio(NIF) ON DELETE CASCADE,
    CONSTRAINT fk_pedido_veiculo FOREIGN KEY (matricula) REFERENCES Veiculo_de_Socio(Matricula),
    CONSTRAINT fk_pedido_turno FOREIGN KEY (num_empregado_turno, data_desde_turno) REFERENCES Turno(num_empregado, data_desde),
        
    CONSTRAINT ck_ria_37 CHECK (num_sequencial >= 1),
    CONSTRAINT ck_ria_38 CHECK (estado IN ('ASSISTÊNCIA PEDIDA', 'ASSISTÊNCIA EM CURSO', 'ASSISTÊNCIA CONCLUÍDA')),
    
    CONSTRAINT ck_ria_39_40 CHECK (
        (estado = 'ASSISTÊNCIA PEDIDA') OR 
        (estado = 'ASSISTÊNCIA EM CURSO' AND data_inicio IS NOT NULL) OR 
        (estado = 'ASSISTÊNCIA CONCLUÍDA' AND data_inicio IS NOT NULL AND data_conclusao IS NOT NULL)
    ),
    
    CONSTRAINT ck_ria_14 CHECK (data_inicio IS NULL OR data_inicio > data_pedido),
    CONSTRAINT ck_ria_16 CHECK (data_conclusao IS NULL OR data_conclusao > data_inicio)
);

INSERT INTO Morada (id_morada, rua, num_porta, codigo_postal, localidade, distrito) 
VALUES (1, 'Rua Augusta', 10, '1000-100', 'Lisboa', 'Lisboa');
INSERT INTO Morada (id_morada, rua, num_porta, codigo_postal, localidade, distrito) 
VALUES (2, 'Rua de Santa Catarina', 50, '4000-441', 'Porto', 'Porto');

INSERT INTO Base (codigo, lugares_garagem, id_morada) VALUES ('LIS1', 5, 1);
INSERT INTO Base (codigo, lugares_garagem, id_morada) VALUES ('POR1', 3, 2);

INSERT INTO Pessoa (NIF, NIC, Nome, Nascimento, Genero, Telemovel, id_morada) 
VALUES (123456789, 12345678, 'Joao Mario', DATE '2000-05-15', 'Masculino', '912345678', 1);
INSERT INTO Pessoa (NIF, NIC, Nome, Nascimento, Genero, Telemovel, id_morada) 
VALUES (112345678, 23456781, 'Maria Costa', DATE '1999-08-20', 'Feminino', '923456789', 2);
INSERT INTO Pessoa (NIF, NIC, Nome, Nascimento, Genero, Telemovel, id_morada) 
VALUES (999888777, 87654321, 'Carlos Silva', DATE '1985-01-01', 'Masculino', '933333333', 1);
INSERT INTO Pessoa (NIF, NIC, Nome, Nascimento, Genero, Telemovel, id_morada) 
VALUES (888777666, 12344321, 'Ana Gomes', DATE '1990-10-10', 'Feminino', '966666666', 2);

INSERT INTO Socio (NIF, Numero) VALUES (123456789, 100001);
INSERT INTO Socio (NIF, Numero) VALUES (112345678, 100002);

INSERT INTO Mecanico (NIF, num_empregado, codigo_base) VALUES (999888777, 12345, 'LIS1');
INSERT INTO Mecanico (NIF, num_empregado, codigo_base) VALUES (888777666, 54321, 'POR1');

INSERT INTO Veiculo (Matricula, Marca, Modelo, Tipo, Ano) VALUES ('AA-12-34', 'Toyota', 'Lexus', 'Automóvel', 2020);
INSERT INTO Veiculo (Matricula, Marca, Modelo, Tipo, Ano) VALUES ('12-34-AB', 'Honda', 'CB500', 'Moto', 2022);
INSERT INTO Veiculo (Matricula, Marca, Modelo, Tipo, Ano) VALUES ('99-ZZ-99', 'Mercedes-Benz', 'Sprinter', 'Automóvel', 2021);
INSERT INTO Veiculo (Matricula, Marca, Modelo, Tipo, Ano) VALUES ('88-XX-88', 'Renault', 'Master', 'Automóvel', 2023);

INSERT INTO Veiculo_de_Socio (Matricula, Cor) VALUES ('AA-12-34', 'Branco');
INSERT INTO Veiculo_de_Socio (Matricula, Cor) VALUES ('12-34-AB', 'Preto');

INSERT INTO Veiculo_de_Assistencia (Matricula, Numero, codigo_base) VALUES ('99-ZZ-99', 1001, 'LIS1');
INSERT INTO Veiculo_de_Assistencia (Matricula, Numero, codigo_base) VALUES ('88-XX-88', 1002, 'POR1');

INSERT INTO Possui (NIF, Matricula, Desde, Ate) VALUES (123456789, 'AA-12-34', DATE '2020-01-15', NULL);
INSERT INTO Possui (NIF, Matricula, Desde, Ate) VALUES (112345678, '12-34-AB', DATE '2022-06-10', NULL);

INSERT INTO Turno (num_empregado, data_desde, data_ate, matricula_assistencia) 
VALUES (12345, TO_DATE('2026-11-04 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-04 16:00', 'YYYY-MM-DD HH24:MI'), '99-ZZ-99');
INSERT INTO Turno (num_empregado, data_desde, data_ate, matricula_assistencia) 
VALUES (54321, TO_DATE('2026-11-05 08:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-05 16:00', 'YYYY-MM-DD HH24:MI'), '88-XX-88');

INSERT INTO Pedido_Assistencia (NIF_socio, num_sequencial, matricula, data_pedido, problema, estado, morada_aproximada, data_inicio, data_conclusao, num_empregado_turno, data_desde_turno) 
VALUES (123456789, 1, 'AA-12-34', TO_DATE('2026-11-04 10:00', 'YYYY-MM-DD HH24:MI'), 'Furo no pneu', 'ASSISTÊNCIA EM CURSO', 'A1 km 45', TO_DATE('2026-11-04 11:00', 'YYYY-MM-DD HH24:MI'), NULL, 12345, TO_DATE('2026-11-04 08:00', 'YYYY-MM-DD HH24:MI'));

INSERT INTO Pedido_Assistencia (NIF_socio, num_sequencial, matricula, data_pedido, problema, estado, morada_aproximada, data_inicio, data_conclusao, num_empregado_turno, data_desde_turno) 
VALUES (112345678, 1, '12-34-AB', TO_DATE('2026-11-05 09:00', 'YYYY-MM-DD HH24:MI'), 'Bateria descarregada', 'ASSISTÊNCIA CONCLUÍDA', 'IC19', TO_DATE('2026-11-05 10:00', 'YYYY-MM-DD HH24:MI'), TO_DATE('2026-11-05 11:00', 'YYYY-MM-DD HH24:MI'), 54321, TO_DATE('2026-11-05 08:00', 'YYYY-MM-DD HH24:MI'));


/*
**RESTRIÇÕES NÃO SUPORTADAS**

-- RIA-01: Exige cruzamento dinamico (cross-table) com a tabela Possui para verificar intervalo de datas. Requer Trigger/Assertion.
-- RIA-02: Exige cruzamento dinamico com as tabelas Mecanico e Base para garantir a pertenca do veiculo. Requer Trigger.
-- RIA-03 e RIA-05: Regras de cobertura (COVER) numa especializacao exigem Assertions. Nao e possivel impedir nativamente que uma entidade pai nao tenha filhos.
-- RIA-06 e RIA-07: Validacoes dependentes de SYSDATE (ano atual) nao sao suportadas nativamente num bloco CHECK no Oracle.
-- RIA-09: Evitar intersecao de datas para o mesmo socio/veiculo na tabela Possui exige verificacao de outras linhas (cross-row). Requer Trigger.
-- RIA-11 e RIA-12: Validar choque de horarios no Turno exige cruzamento cross-row para garantir que datas nao se intersetam.
-- RIA-13, RIA-15, RIA-17: Comparações cronologicas dinamicas entre o Pedido e as tabelas Possui e Turno. Requer Trigger.
-- RIA-39 e RIA-40 (Transicoes): O CHECK garante a consistencia do estado com os campos de data nulos ou preenchidos, mas nao garante a "historia da transicao" (evitar que um estado volte para tras). Requer Trigger.
*/
