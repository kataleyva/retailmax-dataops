SELECT u.pais, u.region, SUM(v.total) AS ventas_totales
FROM ventas v
JOIN ubicacion u ON v.id_tienda = u.id_tienda
GROUP BY u.pais, u.region;
