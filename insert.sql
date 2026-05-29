--public.profiles
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_user_meta_data,
    role,
    aud
) VALUES
('00000000-0000-0000-0000-000000000001', 'felipe.wroblewski@admin.com',  crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Felipe Wroblewski","papel":"admin_global"}',   'authenticated', 'authenticated'),
('00000000-0000-0000-0000-000000000010', 'victor.micheluzzi@escola.com', crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Victor Micheluzzi","papel":"admin_escolar"}', 'authenticated', 'authenticated'),
('00000000-0000-0000-0000-000000000011', 'vitor.uler@escola.com',        crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Vitor Uler","papel":"admin_escolar"}',        'authenticated', 'authenticated'),
('00000000-0000-0000-0000-000000000100', 'heitor.fugel@aluno.com',       crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Heitor Fugel","papel":"aluno"}',              'authenticated', 'authenticated'),
('00000000-0000-0000-0000-000000000101', 'caua.cozz@aluno.com',          crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Caua Cozz","papel":"aluno"}',                 'authenticated', 'authenticated'),
('00000000-0000-0000-0000-000000000102', 'ricardo.ferraza@aluno.com',    crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Ricardo Ferraza","papel":"aluno"}',           'authenticated', 'authenticated'),
('00000000-0000-0000-0000-000000000103', 'joao.stahelin@aluno.com',      crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Joao Stahelin","papel":"aluno"}',             'authenticated', 'authenticated'),
('00000000-0000-0000-0000-000000000200', 'lucas.andrade@aluno.com',     crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Lucas Andrade","papel":"aluno"}',               'authenticated', 'authenticated'),
('00000000-0000-0000-0000-000000000201', 'marina.lima@aluno.com',       crypt('Senha@123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"nome_completo":"Marina Lima","papel":"aluno"}',                 'authenticated', 'authenticated');

--public.escolas
INSERT INTO public.escolas (id, nome, cnpj, admin_id) VALUES
('00000000-0000-0000-0001-000000000001', 'Colégio Evangélico Jaragua',  '12345678000199', '00000000-0000-0000-0000-000000000010'),
('00000000-0000-0000-0001-000000000002', 'Bom Jesus',   '98765432000155', '00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0001-000000000003', 'Marista', '11222333000177', '00000000-0000-0000-0000-000000000010'),
('00000000-0000-0000-0001-000000000004', 'Senai',    '44455566000188', '00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0001-000000000005', 'Sesc',    '77788899000111', '00000000-0000-0000-0000-000000000010'),
('00000000-0000-0000-0001-000000000006', 'Furb',           '33344455000122', '00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0001-000000000007', 'Ufpr',           '66677788000133', '00000000-0000-0000-0000-000000000010');

--public.matriculas
INSERT INTO public.matriculas (aluno_id, escola_id) VALUES
('00000000-0000-0000-0000-000000000100', '00000000-0000-0000-0001-000000000001'),
('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0001-000000000001'),
('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0001-000000000002'),
('00000000-0000-0000-0000-000000000103', '00000000-0000-0000-0001-000000000002'),
('00000000-0000-0000-0000-000000000100', '00000000-0000-0000-0001-000000000003'),
('00000000-0000-0000-0000-000000000101', '00000000-0000-0000-0001-000000000004'),
('00000000-0000-0000-0000-000000000102', '00000000-0000-0000-0001-000000000005');

--public.questoes
-- ─── 4. QUESTÕES ─────────────────────────────────────────────
INSERT INTO public.questoes (id, enunciado, alternativas) VALUES
('00000000-0000-0000-0002-000000000001',
 '{"texto": "Qual é o resultado de 5 + 7?"}',
 '[{"indice":0,"texto":"10"},{"indice":1,"texto":"11"},{"indice":2,"texto":"13"},{"indice":3,"texto":"12"},{"gabarito":3}]'),
('00000000-0000-0000-0002-000000000002',
 '{"texto": "Qual é o símbolo de maior na programação?"}',
 '[{"indice":0,"texto":"<"},{"indice":1,"texto":">"},{"indice":2,"texto":"="},{"indice":3,"texto":"!"},{"gabarito":1}]'),
('00000000-0000-0000-0002-000000000003',
 '{"texto": "Como se seleciona todas as colunas de uma tabela no SQL?"}',
 '[{"indice":0,"texto":"SELECT ALL FROM tabela"},{"indice":1,"texto":"GET * FROM tabela"},{"indice":2,"texto":"SELECT * FROM tabela"},{"indice":3,"texto":"FETCH * FROM tabela"},{"gabarito":2}]'),
('00000000-0000-0000-0002-000000000004',
 '{"texto": "Como se declara uma variável em Python?"}',
 '[{"indice":0,"texto":"nome = valor"},{"indice":1,"texto":"var nome = valor"},{"indice":2,"texto":"int nome = valor"},{"indice":3,"texto":"let nome = valor"},{"gabarito":0}]'),
('00000000-0000-0000-0002-000000000005',
 '{"texto": "Qual palavra-chave inicia um laço de repetição em Python?"}',
 '[{"indice":0,"texto":"repeat"},{"indice":1,"texto":"for"},{"indice":2,"texto":"loop"},{"indice":3,"texto":"each"},{"gabarito":1}]'),
('00000000-0000-0000-0002-000000000006',
 '{"texto": "Como se escreve um comentário de linha única em JavaScript?"}',
 '[{"indice":0,"texto":"# comentário"},{"indice":1,"texto":"<!-- comentário -->"},{"indice":2,"texto":"** comentário"},{"indice":3,"texto":"// comentário"},{"gabarito":3}]'),
('00000000-0000-0000-0002-000000000007',
 '{"texto": "O que é um array na programação?"}',
 '[{"indice":0,"texto":"Uma estrutura que armazena múltiplos valores em sequência"},{"indice":1,"texto":"Um tipo de função que retorna verdadeiro ou falso"},{"indice":2,"texto":"Um comando para conectar ao banco de dados"},{"indice":3,"texto":"Um operador lógico"},{"gabarito":0}]'),
 ('00000000-0000-0000-0002-000000000045',
 '{"texto": "O que é uma função recursiva?"}',
 '[{"indice":0,"texto":"Uma função que nunca termina"},{"indice":1,"texto":"Uma função que chama a si mesma"},{"indice":2,"texto":"Uma função sem parâmetros"},{"indice":3,"texto":"Uma função que retorna zero"},{"gabarito":1}]');

--public.sessoes_simulado
INSERT INTO public.sessoes_simulado
    (id, aluno_id, status, iniciada_em, finalizada_em, total_questoes, total_acertos)
VALUES
('00000000-0000-0000-0003-000000000001', '00000000-0000-0000-0000-000000000100', 'concluida',    '2025-03-01 08:00', '2025-03-01 09:00', 0, 0),
('00000000-0000-0000-0003-000000000002', '00000000-0000-0000-0000-000000000100', 'concluida',    '2025-04-05 14:00', '2025-04-05 15:00', 0, 0),
('00000000-0000-0000-0003-000000000003', '00000000-0000-0000-0000-000000000101', 'concluida',    '2025-03-10 09:00', '2025-03-10 10:00', 0, 0),
('00000000-0000-0000-0003-000000000004', '00000000-0000-0000-0000-000000000102', 'concluida',    '2025-03-12 10:00', '2025-03-12 11:00', 0, 0),
('00000000-0000-0000-0003-000000000005', '00000000-0000-0000-0000-000000000103', 'concluida',    '2025-03-15 11:00', '2025-03-15 12:00', 0, 0),
('00000000-0000-0000-0003-000000000006', '00000000-0000-0000-0000-000000000101', 'em_andamento', '2025-05-01 10:00', NULL,               0, 0),
('00000000-0000-0000-0003-000000000007', '00000000-0000-0000-0000-000000000102', 'em_andamento', '2025-05-10 14:00', NULL,               0, 0),
('00000000-0000-0000-0003-000000000300', '00000000-0000-0000-0000-000000000100', 'concluida', '2025-05-01 09:00',    '2025-05-01 10:00', 0, 0),
('00000000-0000-0000-0003-000000000301', '00000000-0000-0000-0000-000000000101', 'concluida', '2025-05-02 14:00',    '2025-05-02 15:00', 0, 0),
('00000000-0000-0000-0003-000000000400', '00000000-0000-0000-0000-000000000100', 'concluida', '2025-05-10 08:00',    '2025-05-10 09:00', 99, 99),
('00000000-0000-0000-0003-000000000501', '00000000-0000-0000-0000-000000000101', 'concluida', '2025-04-01 08:00', '2025-04-01 10:00', 100, 91),
('00000000-0000-0000-0003-000000000502', '00000000-0000-0000-0000-000000000102', 'concluida', '2025-04-02 08:00', '2025-04-02 10:00', 100, 87),
('00000000-0000-0000-0003-000000000503', '00000000-0000-0000-0000-000000000103', 'concluida', '2025-04-03 08:00', '2025-04-03 10:00', 100, 85),
('00000000-0000-0000-0003-000000000504', '00000000-0000-0000-0000-000000000200', 'concluida', '2025-04-04 08:00', '2025-04-04 10:00', 100, 95);

--public.respostas
INSERT INTO public.respostas (sessao_id, questao_id, alternativa_escolhida, acertou) VALUES
('00000000-0000-0000-0003-000000000001', '00000000-0000-0000-0002-000000000001', 1, true),
('00000000-0000-0000-0003-000000000001', '00000000-0000-0000-0002-000000000002', 2, true),
('00000000-0000-0000-0003-000000000002', '00000000-0000-0000-0002-000000000003', 1, true),
('00000000-0000-0000-0003-000000000003', '00000000-0000-0000-0002-000000000004', 0, false),
('00000000-0000-0000-0003-000000000004', '00000000-0000-0000-0002-000000000005', 1, true),
('00000000-0000-0000-0003-000000000005', '00000000-0000-0000-0002-000000000006', 2, true),
('00000000-0000-0000-0003-000000000005', '00000000-0000-0000-0002-000000000007', 2, true),
('00000000-0000-0000-0003-000000000300', '00000000-0000-0000-0002-000000000045', 0, false),
('00000000-0000-0000-0003-000000000301', '00000000-0000-0000-0002-000000000045', 1, true),
('00000000-0000-0000-0003-000000000400', '00000000-0000-0000-0002-000000000001', 3, true),
('00000000-0000-0000-0003-000000000400', '00000000-0000-0000-0002-000000000002', 2, true),
('00000000-0000-0000-0003-000000000400', '00000000-0000-0000-0002-000000000003', 0, false);