-- Questão 7.5a
SELECT
	d.nome_departamento AS nome_departamento,
	COUNT(*) AS total_funcionarios
FROM empresa.funcionario f
JOIN empresa.departamento d 
	ON d.numero_departamento = f.numero_departamento
GROUP BY d.nome_departamento
HAVING AVG(f.salario) > 30000;

-- Questão 7.5b
SELECT * FROM empresa.funcionario;
SELECT * FROM empresa.departamento;


SELECT
	d.nome_departamento AS departamento,
	COUNT(*) AS total_funcionarios_masculinos
FROM empresa.funcionario f
JOIN empresa.departamento d 
	ON d.numero_departamento = f.numero_departamento
WHERE f.sexo = 'M'
GROUP BY departamento
HAVING AVG(f.salario) > 30000;




-- Questão 7.6

-- Criação das tabelas
CREATE TABLE ALUNO (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    Numero_aluno INT UNIQUE, -- Mantém o número do aluno como identificador lógico
    Nome VARCHAR(50),
    Tipo_aluno INT,
    Curso VARCHAR(10)
);

CREATE TABLE DISCIPLINA (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    Numero_disciplina VARCHAR(10) UNIQUE,
    Nome_disciplina VARCHAR(100),
    Creditos INT,
    Departamento VARCHAR(10)
);

CREATE TABLE PRE_REQUISITO (
    Numero_disciplina VARCHAR(10),
    Numero_pre_requisito VARCHAR(10),
    PRIMARY KEY (Numero_disciplina, Numero_pre_requisito),
    FOREIGN KEY (Numero_disciplina) REFERENCES DISCIPLINA(Numero_disciplina),
    FOREIGN KEY (Numero_pre_requisito) REFERENCES DISCIPLINA(Numero_disciplina)
);


CREATE TABLE TURMA (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    Numero_disciplina VARCHAR(10),
    Semestre VARCHAR(20),
    Ano INT,
    Professor VARCHAR(50),
    FOREIGN KEY (Numero_disciplina) REFERENCES DISCIPLINA(Numero_disciplina)
);

CREATE TABLE REGISTRO_NOTA (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    aluno_id BIGINT,
    turma_id BIGINT,
    Nota CHAR(1),
    FOREIGN KEY (aluno_id) REFERENCES ALUNO(id),
    FOREIGN KEY (turma_id) REFERENCES TURMA(id),
    UNIQUE (aluno_id, turma_id)
);

INSERT INTO ALUNO (Numero_aluno, Nome, Tipo_aluno, Curso)
VALUES 
    (17, 'Silva', 1, 'CC'),
    (8, 'Braga', 2, 'CC');

INSERT INTO PRE_REQUISITO (Numero_disciplina, Numero_pre_requisito)
VALUES
    ('CC3380', 'CC3320'),
    ('CC3380', 'MAT2410'),
    ('CC3320', 'CC1310');

INSERT INTO DISCIPLINA (Numero_disciplina, Nome_disciplina, Creditos, Departamento)
VALUES 
    ('CC1310', 'Introdução à ciência da computação', 4, 'CC'),
    ('CC3320', 'Estruturas de dados', 4, 'CC'),
    ('MAT2410', 'Matemática discreta', 3, 'MAT'),
    ('CC3380', 'Banco de dados', 3, 'CC');


-- Obtém os IDs das disciplinas para mapear corretamente
WITH disciplina_ids AS (
    SELECT id, Numero_disciplina FROM DISCIPLINA
)
INSERT INTO PRE_REQUISITO (disciplina_id, pre_requisito_id)
VALUES
    ((SELECT id FROM disciplina_ids WHERE Numero_disciplina = 'CC3380'), 
     (SELECT id FROM disciplina_ids WHERE Numero_disciplina = 'CC3320')),

    ((SELECT id FROM disciplina_ids WHERE Numero_disciplina = 'CC3380'), 
     (SELECT id FROM disciplina_ids WHERE Numero_disciplina = 'MAT2410')),

    ((SELECT id FROM disciplina_ids WHERE Numero_disciplina = 'CC3320'), 
     (SELECT id FROM disciplina_ids WHERE Numero_disciplina = 'CC1310'));


INSERT INTO TURMA (Numero_disciplina, Semestre, Ano, Professor)
VALUES 
    ('MAT2410', 'Segundo', 07, 'Kleber'),
    ('CC1310', 'Segundo', 07, 'Anderson'),
    ('CC3320', 'Primeiro', 08, 'Carlos'),
    ('MAT2410', 'Segundo', 08, 'Chang'),
    ('CC1310', 'Segundo', 08, 'Anderson'),
    ('CC3380', 'Segundo', 08, 'Santos');



-- Obtém os IDs dos alunos e das turmas para relacionar corretamente
WITH aluno_ids AS (
    SELECT id, Numero_aluno FROM ALUNO
),
turma_ids AS (
    SELECT id, Numero_disciplina, Semestre, Ano FROM TURMA
)
INSERT INTO REGISTRO_NOTA (aluno_id, turma_id, Nota)
VALUES
    ((SELECT id FROM aluno_ids WHERE Numero_aluno = 17),
     (SELECT id FROM turma_ids WHERE Numero_disciplina = 'MAT2410' AND Semestre = 'Segundo' AND Ano = 08),
     'B'),

    ((SELECT id FROM aluno_ids WHERE Numero_aluno = 17),
     (SELECT id FROM turma_ids WHERE Numero_disciplina = 'CC1310' AND Semestre = 'Segundo' AND Ano = 08),
     'C'),

    ((SELECT id FROM aluno_ids WHERE Numero_aluno = 8),
     (SELECT id FROM turma_ids WHERE Numero_disciplina = 'MAT2410' AND Semestre = 'Segundo' AND Ano = 07),
     'A'),

    ((SELECT id FROM aluno_ids WHERE Numero_aluno = 8),
     (SELECT id FROM turma_ids WHERE Numero_disciplina = 'CC1310' AND Semestre = 'Segundo' AND Ano = 07),
     'A'),

    ((SELECT id FROM aluno_ids WHERE Numero_aluno = 8),
     (SELECT id FROM turma_ids WHERE Numero_disciplina = 'CC3320' AND Semestre = 'Primeiro' AND Ano = 08),
     'B'),

    ((SELECT id FROM aluno_ids WHERE Numero_aluno = 8),
     (SELECT id FROM turma_ids WHERE Numero_disciplina = 'CC3380' AND Semestre = 'Segundo' AND Ano = 08),
     'A');

-- 7.6a

SELECT * FROM registro_nota;
SELECT * FROM aluno;
SELECT * FROM disciplina;
SELECT * FROM turma;



SELECT 
	a.nome, 
	a.curso
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1
    FROM registro_nota rn
    WHERE rn.aluno_id = a.id
    AND rn.nota <> 'A'
);


SELECT 
	a.nome, 
	a.curso
FROM aluno a
WHERE EXISTS (
    SELECT 1
    FROM registro_nota rn
    WHERE rn.aluno_id = a.id
    AND rn.nota <> 'A'
);

-- 7.7a

SET search_path TO empresa;
SELECT * FROM departamento;
SELECT * FROM dependente;
SELECT * FROM funcionario;

SELECT 
	f.primeiro_nome AS nome_funcionario,
	f.salario AS salario
FROM funcionario f 
WHERE f.numero_departamento = (
	SELECT
		numero_departamento
	FROM funcionario
	WHERE salario = (SELECT MAX(salario) FROM funcionario)
);

-- 7.7b

SELECT
	primeiro_nome AS nome_funcionario
FROM funcionario
WHERE cpf_supervisor = '88866555576';


-- 7.7c
SELECT 
	primeiro_nome AS nome_funcionario,  
	salario
FROM funcionario
WHERE salario >= (
    SELECT MIN(salario) FROM funcionario
) + 10000;

