CREATE TABLE public.profiles (
    id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nome_completo TEXT        NOT NULL,
    papel         public.user_role NOT NULL DEFAULT 'aluno',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.escolas (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    nome       TEXT        NOT NULL,
    cnpj       CHAR(14)    NOT NULL,
    admin_id   UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT escolas_cnpj_unique UNIQUE (cnpj)
);

CREATE TABLE public.matriculas (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id   UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    escola_id  UUID        NOT NULL REFERENCES public.escolas(id)  ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT matriculas_aluno_escola_unique UNIQUE (aluno_id, escola_id)
);

CREATE TABLE public.questoes (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_interno INT         GENERATED ALWAYS AS IDENTITY UNIQUE,
    enunciado      JSONB       NOT NULL,
    alternativas   JSONB       NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.sessoes_simulado (
    id              UUID                  PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id        UUID                  NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status          public.sessao_status  NOT NULL DEFAULT 'em_andamento',
    iniciada_em     TIMESTAMPTZ           NOT NULL DEFAULT NOW(),
    finalizada_em   TIMESTAMPTZ,
    total_questoes  INT                   NOT NULL DEFAULT 0,
    total_acertos   INT                   NOT NULL DEFAULT 0,

    CONSTRAINT sessao_datas_check
        CHECK (finalizada_em IS NULL OR finalizada_em >= iniciada_em),

    CONSTRAINT sessao_acertos_check
        CHECK (total_acertos >= 0 AND total_acertos <= total_questoes)
);

CREATE TABLE public.respostas (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    sessao_id             UUID        NOT NULL REFERENCES public.sessoes_simulado(id) ON DELETE CASCADE,
    questao_id            UUID        NOT NULL REFERENCES public.questoes(id)         ON DELETE CASCADE,
    alternativa_escolhida INT         NOT NULL,
    acertou               BOOLEAN     NOT NULL,
    respondida_em         TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT respostas_sessao_questao_unique
        UNIQUE (sessao_id, questao_id)
);