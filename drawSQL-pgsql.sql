CREATE TABLE "position_technology"(
    "position_id" SERIAL NOT NULL,
    "technology_id" SERIAL NOT NULL,
    "experience_level" VARCHAR(255) CHECK
        ("experience_level" IN('')) NOT NULL
);
ALTER TABLE
    "position_technology" ADD PRIMARY KEY("position_id");
ALTER TABLE
    "position_technology" ADD PRIMARY KEY("technology_id");
CREATE TABLE "user_technology"(
    "user_id" SERIAL NOT NULL,
    "technology_id" SERIAL NOT NULL,
    "experience_level" VARCHAR(255) CHECK
        ("experience_level" IN('')) NOT NULL
);
ALTER TABLE
    "user_technology" ADD PRIMARY KEY("user_id");
ALTER TABLE
    "user_technology" ADD PRIMARY KEY("technology_id");
CREATE TABLE "link"(
    "id" SERIAL NOT NULL,
    "user_id" SERIAL NOT NULL,
    "url" VARCHAR(255) NOT NULL,
    "description" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "link" ADD PRIMARY KEY("id");
CREATE INDEX "link_user_id_index" ON
    "link"("user_id");
CREATE TABLE "user_specialization"(
    "user_id" SERIAL NOT NULL,
    "specialization_type" VARCHAR(255) CHECK
        ("specialization_type" IN('')) NOT NULL,
        "experience_level" VARCHAR(255)
    CHECK
        ("experience_level" IN('')) NOT NULL
);
ALTER TABLE
    "user_specialization" ADD PRIMARY KEY("user_id");
CREATE TABLE "synonyms"(
    "technology_id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "synonyms" ADD PRIMARY KEY("technology_id");
CREATE TABLE "experience"(
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "position" VARCHAR(255) NOT NULL,
    "company_name" VARCHAR(255) NOT NULL,
    "duration_month" INTEGER NOT NULL,
    "industry" VARCHAR(255) NULL,
    "team_size" VARCHAR(255) NULL
);
ALTER TABLE
    "experience" ADD PRIMARY KEY("id");
CREATE INDEX "experience_user_id_index" ON
    "experience"("user_id");
CREATE TABLE "user_account"(
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "surname" VARCHAR(255) NULL,
    "email" VARCHAR(255) NOT NULL,
    "phone_number" VARCHAR(255) NULL,
    "country" VARCHAR(255) NULL,
    "city" VARCHAR(255) NULL,
    "hours_per_week" INTEGER NULL,
    "exp_start_date" INTEGER NOT NULL,
    "profile_picture" VARCHAR(255) NULL,
    "created_at" TIMESTAMP(0) WITHOUT TIME ZONE NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(0) WITHOUT TIME ZONE NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE
    "user_account" ADD PRIMARY KEY("id");
ALTER TABLE
    "user_account" ADD CONSTRAINT "user_account_email_unique" UNIQUE("email");
CREATE TABLE "position"(
    "id" SERIAL NOT NULL,
    "project_id" SERIAL NOT NULL,
    "specialization_type" VARCHAR(255) CHECK
        ("specialization_type" IN('')) NOT NULL,
        "capacity" INTEGER NOT NULL DEFAULT '1',
        "remaining_capacity" INTEGER NOT NULL DEFAULT '1',
        "experience_level" VARCHAR(255)
    CHECK
        ("experience_level" IN('')) NOT NULL
);
ALTER TABLE
    "position" ADD PRIMARY KEY("id");
ALTER TABLE
    "position" ADD PRIMARY KEY("project_id");
CREATE TABLE "technology"(
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "technology" ADD PRIMARY KEY("id");
CREATE TABLE "contract"(
    "id" SERIAL NOT NULL,
    "duration" VARCHAR(255) NULL,
    "type" VARCHAR(255) CHECK
        (
            "type" IN('hourly', 'project_based')
        ) NOT NULL,
        "hours_per_week" INTEGER NULL
);
ALTER TABLE
    "contract" ADD PRIMARY KEY("id");
CREATE TABLE "project"(
    "id" SERIAL NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "contract_id" VARCHAR(255) CHECK
        ("contract_id" IN('')) NOT NULL,
        "active" BOOLEAN NOT NULL DEFAULT '1',
        "priority_level" SMALLINT NULL,
        "created_at" TIMESTAMP(0) WITHOUT TIME ZONE NULL DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP(0) WITHOUT TIME ZONE NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE
    "project" ADD PRIMARY KEY("id");
CREATE TABLE "application"(
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NULL,
    "project_id" INTEGER NULL,
    "applied_position" VARCHAR(100) NULL,
    "status" VARCHAR(50) NULL,
    "specialization_type" VARCHAR(255) CHECK
        ("specialization_type" IN('')) NOT NULL,
        "application_date" TIMESTAMP(0) WITHOUT TIME ZONE NULL DEFAULT CURRENT_TIMESTAMP,
        "updated_at" TIMESTAMP(0) WITHOUT TIME ZONE NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE
    "application" ADD PRIMARY KEY("id");
CREATE INDEX "application_user_id_index" ON
    "application"("user_id");
CREATE INDEX "application_project_id_index" ON
    "application"("project_id");
ALTER TABLE
    "application" ADD CONSTRAINT "application_user_id_foreign" FOREIGN KEY("user_id") REFERENCES "user_account"("id");
ALTER TABLE
    "user_account" ADD CONSTRAINT "user_account_id_foreign" FOREIGN KEY("id") REFERENCES "user_technology"("user_id");
ALTER TABLE
    "link" ADD CONSTRAINT "link_user_id_foreign" FOREIGN KEY("user_id") REFERENCES "user_account"("id");
ALTER TABLE
    "user_account" ADD CONSTRAINT "user_account_id_foreign" FOREIGN KEY("id") REFERENCES "user_specialization"("user_id");
ALTER TABLE
    "technology" ADD CONSTRAINT "technology_id_foreign" FOREIGN KEY("id") REFERENCES "user_technology"("technology_id");
ALTER TABLE
    "experience" ADD CONSTRAINT "experience_user_id_foreign" FOREIGN KEY("user_id") REFERENCES "user_account"("id");
ALTER TABLE
    "project" ADD CONSTRAINT "project_contract_id_foreign" FOREIGN KEY("contract_id") REFERENCES "contract"("id");
ALTER TABLE
    "application" ADD CONSTRAINT "application_project_id_foreign" FOREIGN KEY("project_id") REFERENCES "project"("id");
ALTER TABLE
    "technology" ADD CONSTRAINT "technology_id_foreign" FOREIGN KEY("id") REFERENCES "synonyms"("technology_id");
ALTER TABLE
    "position" ADD CONSTRAINT "position_project_id_foreign" FOREIGN KEY("project_id") REFERENCES "project"("id");
ALTER TABLE
    "position_technology" ADD CONSTRAINT "position_technology_position_id_foreign" FOREIGN KEY("position_id") REFERENCES "position"("id");
ALTER TABLE
    "technology" ADD CONSTRAINT "technology_id_foreign" FOREIGN KEY("id") REFERENCES "position_technology"("technology_id");