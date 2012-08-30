CREATE TABLE entries
(
  id serial NOT NULL,
  parent_id integer,
  created_time timestamp without time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  content text NOT NULL,
  tags text NOT NULL,
  priority integer NOT NULL DEFAULT 0,
  CONSTRAINT entries_pkey PRIMARY KEY (id ),
  CONSTRAINT entries_parent_id_fkey FOREIGN KEY (parent_id)
      REFERENCES entries (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
