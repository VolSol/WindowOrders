CREATE TABLE material_groups
(
    material_group_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_group_name CITEXT NOT NULL,
    CONSTRAINT uq_material_groups_material_group_name
        UNIQUE (material_group_name)
);

CREATE TABLE material_types
(
    material_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_group_id BIGINT NOT NULL,
    material_type_name CITEXT NOT NULL,

    CONSTRAINT fk_material_types_material_groups
        FOREIGN KEY (material_group_id)
        REFERENCES material_groups(material_group_id),

    CONSTRAINT uq_material_types_group_name
        UNIQUE (material_group_id, material_type_name)
);

CREATE INDEX ix_material_types_material_group_id
    ON material_types(material_group_id);

CREATE TABLE materials
(
    material_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_type_id BIGINT NOT NULL,
    material_name CITEXT NOT NULL,
    article VARCHAR(100),
    metric VARCHAR(50),
    unit_price NUMERIC(18,2) NOT NULL DEFAULT 0,
    waste_percent NUMERIC(8,2) NOT NULL DEFAULT 0,
    note TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_materials_material_types
        FOREIGN KEY (material_type_id)
        REFERENCES material_types(material_type_id)
);

CREATE INDEX ix_materials_material_type_id
    ON materials(material_type_id);

CREATE INDEX ix_materials_material_name
    ON materials
    USING gin(material_name gin_trgm_ops);

CREATE TABLE orders
(
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    customer_name VARCHAR(300) NOT NULL,
    customer_phone VARCHAR(50),
    order_status VARCHAR(30) NOT NULL DEFAULT 'Draft',
    q_1 TEXT,
    q_2 TEXT,

    CONSTRAINT uq_orders_order_number
        UNIQUE(order_number)
);

CREATE INDEX ix_orders_order_number
    ON orders(order_number);

CREATE INDEX ix_orders_customer_name
    ON orders(customer_name);

CREATE INDEX ix_orders_order_date
    ON orders(order_date);

CREATE TABLE products
(
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_name VARCHAR(300) NOT NULL,
    quantity NUMERIC(18,3) NOT NULL DEFAULT 1,
    unit_price NUMERIC(18,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_products_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
);

CREATE INDEX ix_products_order_id
    ON products(order_id);

CREATE INDEX ix_products_product_name
    ON products(product_name);

CREATE TABLE product_components
(
    product_component_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,

    component_name VARCHAR(300),
    quantity NUMERIC(18,3) NOT NULL DEFAULT 1,
    material_quantity NUMERIC(18,3) NOT NULL DEFAULT 0,
    unit_price NUMERIC(18,2) NOT NULL DEFAULT 0,
    waste_quantity NUMERIC(18,3),
    total_price NUMERIC(18,2),
    note TEXT,
    length NUMERIC(18,3),
    width NUMERIC(18,3),

    CONSTRAINT fk_product_components_products
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_product_components_materials
        FOREIGN KEY (material_id)
        REFERENCES materials(material_id)
);

CREATE INDEX ix_product_components_product_id
    ON product_components(product_id);

CREATE INDEX ix_product_components_material_id
    ON product_components(material_id);

CREATE TABLE material_embeddings
(
    material_id BIGINT PRIMARY KEY,
    embedding VECTOR(384),

    CONSTRAINT fk_material_embeddings_materials
        FOREIGN KEY(material_id)
        REFERENCES materials(material_id)
        ON DELETE CASCADE
);

CREATE VIEW v_order_details AS
SELECT
    o.order_id,
    o.order_number,
    o.order_date,
    o.customer_name,
    o.customer_phone,
    o.order_status,

    p.product_id,
    p.product_name,
    p.quantity AS product_quantity,
    p.unit_price AS product_unit_price,

    pc.product_component_id,
    pc.component_name,
    pc.quantity AS component_quantity,
    pc.material_quantity,
    pc.unit_price AS component_unit_price,
    pc.waste_quantity,
    pc.total_price,
    pc.length,
    pc.width,

    m.material_id,
    m.material_name,
    m.article,
    m.metric,
    m.unit_price AS material_unit_price,
    m.waste_percent,

    mt.material_type_id,
    mt.material_type_name,

    mg.material_group_id,
    mg.material_group_name

FROM orders o
JOIN products p
    ON p.order_id = o.order_id
JOIN product_components pc
    ON pc.product_id = p.product_id
JOIN materials m
    ON m.material_id = pc.material_id
JOIN material_types mt
    ON mt.material_type_id = m.material_type_id
JOIN material_groups mg
    ON mg.material_group_id = mt.material_group_id;