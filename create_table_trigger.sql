CREATE TYPE public.user_role AS ENUM (
    'aluno',
    'admin_escolar',
    'admin_global'
);


CREATE TABLE public.profiles (
    id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nome_completo TEXT        NOT NULL,
    papel         public.user_role NOT NULL DEFAULT 'aluno',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public        
AS $$
BEGIN
    INSERT INTO public.profiles (id, nome_completo, papel)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'nome_completo', NEW.email),
        COALESCE(
            (NEW.raw_user_meta_data->>'papel')::public.user_role,
            'aluno'
        )
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TABLE public.escolas (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    nome       TEXT        NOT NULL,
    cnpj       CHAR(14)    NOT NULL,
    admin_id   UUID        NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT escolas_cnpj_unique UNIQUE (cnpj)
);

CREATE OR REPLACE FUNCTION public.check_admin_escolar_papel()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = NEW.admin_id AND papel = 'admin_escolar'
    ) THEN
        RAISE EXCEPTION 'admin_id deve referenciar um usuário com papel admin_escolar';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_escolas_check_admin
    BEFORE INSERT OR UPDATE ON public.escolas
    FOR EACH ROW EXECUTE FUNCTION public.check_admin_escolar_papel();

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

CREATE TRIGGER trg_questoes_updated_at
    BEFORE UPDATE ON public.questoes
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TYPE public.sessao_status AS ENUM ('em_andamento', 'concluida');

CREATE TABLE public.sessoes_simulado (
    id              UUID                  PRIMARY KEY DEFAULT gen_random_uuid(),
    aluno_id        UUID                  NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    status          public.sessao_status  NOT NULL DEFAULT 'em_andamento',
    iniciada_em     TIMESTAMPTZ           NOT NULL DEFAULT NOW(),
    finalizada_em   TIMESTAMPTZ,
    total_questoes  INT                   NOT NULL DEFAULT 0,
    total_acertos   INT                   NOT NULL DEFAULT 0,

    CONSTRAINT sessao_datas_check   CHECK (finalizada_em IS NULL OR finalizada_em >= iniciada_em),
    CONSTRAINT sessao_acertos_check CHECK (total_acertos >= 0 AND total_acertos <= total_questoes)
);

CREATE TABLE public.respostas (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    sessao_id             UUID        NOT NULL REFERENCES public.sessoes_simulado(id) ON DELETE CASCADE,
    questao_id            UUID        NOT NULL REFERENCES public.questoes(id)         ON DELETE CASCADE,
    alternativa_escolhida INT         NOT NULL,
    acertou               BOOLEAN     NOT NULL,
    respondida_em         TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT respostas_sessao_questao_unique UNIQUE (sessao_id, questao_id)
);

CREATE OR REPLACE FUNCTION public.atualiza_contadores_sessao()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.sessoes_simulado
    SET
        total_questoes = total_questoes + 1,
        total_acertos  = total_acertos  + (CASE WHEN NEW.acertou THEN 1 ELSE 0 END)
    WHERE id = NEW.sessao_id;
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_resposta_inserida
    AFTER INSERT ON public.respostas
    FOR EACH ROW EXECUTE FUNCTION public.atualiza_contadores_sessao();

CREATE INDEX idx_matriculas_aluno   ON public.matriculas(aluno_id);
CREATE INDEX idx_matriculas_escola  ON public.matriculas(escola_id);
CREATE INDEX idx_sessoes_aluno      ON public.sessoes_simulado(aluno_id);
CREATE INDEX idx_respostas_sessao   ON public.respostas(sessao_id);
CREATE INDEX idx_respostas_questao  ON public.respostas(questao_id);

ALTER TABLE public.profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.escolas            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matriculas         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questoes           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessoes_simulado   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.respostas          ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS public.user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT papel FROM public.profiles WHERE id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.escola_do_admin()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT id FROM public.escolas WHERE admin_id = auth.uid()
$$;


CREATE POLICY "aluno: ver próprio perfil"
    ON public.profiles FOR SELECT
    USING (id = auth.uid());

CREATE POLICY "aluno: editar próprio perfil"
    ON public.profiles FOR UPDATE
    USING (id = auth.uid());

CREATE POLICY "trigger: inserir perfil"
    ON public.profiles FOR INSERT
    WITH CHECK (id = auth.uid());

CREATE POLICY "admin_escolar: ver alunos da escola"
    ON public.profiles FOR SELECT
    USING (
        public.current_user_role() = 'admin_escolar'
        AND id IN (
            SELECT aluno_id FROM public.matriculas
            WHERE escola_id = public.escola_do_admin()
        )
    );

CREATE POLICY "admin_global: acesso total a profiles"
    ON public.profiles FOR ALL
    USING (public.current_user_role() = 'admin_global');


CREATE POLICY "admin_escolar: ver própria escola"
    ON public.escolas FOR SELECT
    USING (admin_id = auth.uid());

CREATE POLICY "admin_escolar: editar própria escola"
    ON public.escolas FOR UPDATE
    USING (admin_id = auth.uid());

CREATE POLICY "admin_global: acesso total a escolas"
    ON public.escolas FOR ALL
    USING (public.current_user_role() = 'admin_global');


CREATE POLICY "aluno: ver próprias matrículas"
    ON public.matriculas FOR SELECT
    USING (aluno_id = auth.uid());

CREATE POLICY "admin_escolar: gerenciar matrículas da escola"
    ON public.matriculas FOR ALL
    USING (escola_id = public.escola_do_admin());

CREATE POLICY "admin_global: acesso total a matrículas"
    ON public.matriculas FOR ALL
    USING (public.current_user_role() = 'admin_global');


CREATE POLICY "autenticado: ler acervo de questões"
    ON public.questoes FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "admin_global: gerenciar questões"
    ON public.questoes FOR ALL
    USING (public.current_user_role() = 'admin_global');


CREATE POLICY "aluno: acesso às próprias sessões"
    ON public.sessoes_simulado FOR ALL
    USING (aluno_id = auth.uid());

CREATE POLICY "admin_escolar: auditar sessões da escola"
    ON public.sessoes_simulado FOR SELECT
    USING (
        public.current_user_role() = 'admin_escolar'
        AND aluno_id IN (
            SELECT aluno_id FROM public.matriculas
            WHERE escola_id = public.escola_do_admin()
        )
    );

CREATE POLICY "admin_global: acesso total a sessões"
    ON public.sessoes_simulado FOR ALL
    USING (public.current_user_role() = 'admin_global');


CREATE POLICY "aluno: acesso às próprias respostas"
    ON public.respostas FOR ALL
    USING (
        sessao_id IN (
            SELECT id FROM public.sessoes_simulado
            WHERE aluno_id = auth.uid()
        )
    );

CREATE POLICY "admin_escolar: auditar respostas da escola"
    ON public.respostas FOR SELECT
    USING (
        public.current_user_role() = 'admin_escolar'
        AND sessao_id IN (
            SELECT s.id FROM public.sessoes_simulado s
            JOIN public.matriculas m ON m.aluno_id = s.aluno_id
            WHERE m.escola_id = public.escola_do_admin()
        )
    );

CREATE POLICY "admin_global: acesso total a respostas"
    ON public.respostas FOR ALL
    USING (public.current_user_role() = 'admin_global');