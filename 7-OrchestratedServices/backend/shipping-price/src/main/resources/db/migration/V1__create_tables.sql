CREATE SCHEMA shipping_price;
CREATE TABLE shipping_price.route_rate_card
(
    source_country      CHAR(2),
    destination_country VARCHAR(2),
    distance_km         INTEGER,
    rate_per_kg_per_km  FLOAT,
    urgency_multiplier  FLOAT,
    currency            CHAR(3)
);

-- [jooq ignore start]
INSERT INTO shipping_price.route_rate_card (source_country, destination_country, distance_km, rate_per_kg_per_km,
                                            urgency_multiplier, currency)
VALUES ('AE', 'SA', 400, 0.1, 1.2, 'AED'),    -- United Arab Emirates to Saudi Arabia
       ('AE', 'IQ', 1200, 0.11, 1.3, 'AED'),  -- United Arab Emirates to Iraq
       ('AE', 'IR', 1300, 0.12, 1.4, 'AED'),  -- United Arab Emirates to Iran,
       ('AE', 'EG', 2000, 0.08, 1.3, 'AED'),  -- United Arab Emirates to Egypt
       ('AE', 'DZ', 3000, 0.09, 1.4, 'AED'),  -- United Arab Emirates to Algeria
       ('AE', 'ZA', 8500, 0.1, 1.5, 'AED'),   -- United Arab Emirates to South Africa
       ('AE', 'DE', 5000, 0.07, 1.4, 'AED'),  -- United Arab Emirates to Germany
       ('AE', 'UK', 5500, 0.08, 1.5, 'AED'),  -- United Arab Emirates to United Kingdom
       ('AE', 'FR', 6000, 0.09, 1.6, 'AED'),  -- United Arab Emirates to France
       ('AE', 'CN', 6000, 0.06, 1.5, 'AED'),  -- United Arab Emirates to China
       ('AE', 'JP', 7000, 0.07, 1.6, 'AED'),  -- United Arab Emirates to Japan
       ('AE', 'IN', 4000, 0.05, 1.4, 'AED'),  -- United Arab Emirates to India
       ('AE', 'US', 11000, 0.05, 1.6, 'AED'), -- United Arab Emirates to the United States
       ('AE', 'BR', 12000, 0.06, 1.7, 'AED'), -- United Arab Emirates to Brazil
       ('AE', 'MX', 10000, 0.04, 1.5, 'AED');
-- United Arab Emirates to Mexico
-- [jooq ignore stop]