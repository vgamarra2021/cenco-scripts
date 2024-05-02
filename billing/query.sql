select
    *
from
    (
        select
            dispatch_order.external_system_order_id as orden_compra,
            hd_delivery_dispatch_raw_prod_spec.courier.name as sistema,
            hd_delivery_dispatch_raw_prod.dispatch_order.external_driver_id as codigo_conductor,
            case
                when hd_delivery_dispatch_raw_prod_spec.courier.name = 'Beetrack' then tags1.value
                when hd_delivery_dispatch_raw_prod_spec.courier.name = 'Home Delivery Chile' then provider.name
                else hd_delivery_dispatch_raw_prod_spec.courier.name
            end as proveedor,
            case
                when hd_delivery_dispatch_raw_prod_spec.courier.name = 'Beetrack' then tags2.value
                when hd_delivery_dispatch_raw_prod_spec.courier.name = 'Home Delivery Chile' then hd_delivery_tms_raw_prod_spec.vehicle.licence_plate
                else hd_delivery_dispatch_raw_prod_spec.courier.name
            end as patente,
            case
                when hd_delivery_dispatch_raw_prod_spec.courier.name = 'Beetrack' then hd_delivery_dispatch_raw_prod.vehicle_driver.full_name
                else hd_delivery_tms_raw_prod_spec.driver.full_name
            end as nombre_driver,
            retail_chain.name as negocio,
            known_source.external_id as codigo_tienda,
            known_source.name as nombre_tienda,
            tmp_te."event-date" :: timestamp as fecha_evento,
            case
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'PE' then date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-5'
                )
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'CO' then date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-5'
                )
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'AR' then date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-3'
                )
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'BR' then date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-3'
                )
                else date(dispatch_order.eta_end_date :: timestamp)
            end as fecha_compromiso,
            pack2.last_status_desc as nombre_estado,
            pack2.last_sub_status_desc as nombre_sub_estado,
            saz2_destination.name as comuna_destino,
            destination.latitude as latitude,
            destination.longitude as longitude,
            case
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'PE'
                and (
                    DATE_TRUNC(
                        'minute',
                        tmp_te."event-date" :: timestamp - INTERVAL '1 hour'
                    ) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-5'
                    )
                )
                and date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-4'
                ) < '09/03/2023' then 1
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'PE'
                and (
                    DATE_TRUNC(
                        'minute',
                        tmp_te."event-date" :: timestamp - INTERVAL '2 hour'
                    ) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-5'
                    )
                )
                and date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-4'
                ) >= '09/03/2023' then 1
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'CO'
                and (
                    DATE_TRUNC(
                        'minute',
                        tmp_te."event-date" :: timestamp - INTERVAL '1 hour'
                    ) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-5'
                    )
                )
                and date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-4'
                ) < '09/03/2023' then 1
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'CO'
                and (
                    DATE_TRUNC(
                        'minute',
                        tmp_te."event-date" :: timestamp - INTERVAL '2 hour'
                    ) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-5'
                    )
                )
                and date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-4'
                ) >= '09/03/2023' then 1
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'AR'
                and (
                    DATE_TRUNC(
                        'minute',
                        tmp_te."event-date" :: timestamp + INTERVAL '1 hour'
                    ) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-3'
                    )
                )
                and date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-4'
                ) < '09/03/2023' then 1
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'AR'
                and (
                    DATE_TRUNC('minute', tmp_te."event-date" :: timestamp) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-3'
                    )
                )
                and date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-4'
                ) >= '09/03/2023' then 1
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'BR'
                and (
                    DATE_TRUNC(
                        'minute',
                        tmp_te."event-date" :: timestamp + INTERVAL '1 hour'
                    ) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-3'
                    )
                )
                and date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-4'
                ) < '09/03/2023' then 1
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'BR'
                and (
                    DATE_TRUNC('minute', tmp_te."event-date" :: timestamp) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-3'
                    )
                )
                and date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-4'
                ) >= '09/03/2023' then 1
                when hd_delivery_dispatch_raw_prod_spec.country.code = 'CL'
                and (
                    DATE_TRUNC('minute', tmp_te."event-date" :: timestamp) <= DATE_TRUNC('minute', dispatch_order.eta_end_date :: timestamp)
                ) then 1
                else 0
            end as on_time,
            --tags_bultos.total::integer as total_bultos,
            --tags_bultos.size as size,
            dispatch_order.external_system_order_id || '|' || max(dispatch_order.updated_at :: timestamp) as order_key
        from
            hd_delivery_dispatch_raw_prod.dispatch_order --Pack
            left join (
                select
                    *
                from
                    (
                        select
                            pack.dispatch_order_id,
                            pack.tracking,
                            pack.last_status_code,
                            pack.last_status_desc,
                            pack.last_sub_status_code,
                            pack.last_sub_status_desc,
                            pack.tracking || '|' || max(pack.updated_at :: timestamp) as pack_key
                        from
                            hd_delivery_dispatch_raw_prod.pack --where pack.tracking = 'v500140173spid-01'
                        group by
                            1,
                            2,
                            3,
                            4,
                            5,
                            6
                    ) as tempo
                where
                    tempo.pack_key in (
                        select
                            tmp00.pack_key
                        from
(
                                select
                                    pack.tracking,
                                    pack.tracking || '|' || max(pack.updated_at :: timestamp) as pack_key
                                from
                                    hd_delivery_dispatch_raw_prod.pack --where pack.tracking = 'v500140173spid-01'
                                group by
                                    1
                            ) tmp00
                    )
            ) as pack2 on pack2.dispatch_order_id = dispatch_order.id --Destination
            left join hd_delivery_dispatch_raw_prod.destination on destination.id = dispatch_order.destination_id
            left join hd_delivery_dispatch_raw_prod_spec.sub_admin_zone_1 saz1_destination on saz1_destination.id = destination.sub_admin_zone_1_id
            left join hd_delivery_dispatch_raw_prod_spec.sub_admin_zone_2 saz2_destination on saz2_destination.id = destination.sub_admin_zone_2_id --Known Source
            left join hd_delivery_dispatch_raw_prod_spec.known_source on known_source.id = dispatch_order.owner_known_source_id -- Retail chain
            left join hd_delivery_dispatch_raw_prod_spec.retail_chain on hd_delivery_dispatch_raw_prod_spec.retail_chain.id = hd_delivery_dispatch_raw_prod.dispatch_order.retail_chain_id -- Country
            left join hd_delivery_dispatch_raw_prod_spec.country on hd_delivery_dispatch_raw_prod_spec.country.id = hd_delivery_dispatch_raw_prod_spec.retail_chain.country_id -- Dispatch Type
            left join hd_delivery_dispatch_raw_prod_spec.dispatch_type on hd_delivery_dispatch_raw_prod.dispatch_order.dispatch_type_id = hd_delivery_dispatch_raw_prod_spec.dispatch_type.id -- Courier
            left join hd_delivery_dispatch_raw_prod_spec.courier on hd_delivery_dispatch_raw_prod_spec.courier.id = hd_delivery_dispatch_raw_prod.dispatch_order.courier_id -- Driver TMS
            left join hd_delivery_tms_raw_prod_spec.driver on hd_delivery_tms_raw_prod_spec.driver.id = hd_delivery_dispatch_raw_prod.dispatch_order.external_driver_id -- Vehicle
            left join hd_delivery_tms_raw_prod_spec.vehicle on hd_delivery_tms_raw_prod_spec.vehicle.id = hd_delivery_tms_raw_prod_spec.driver.vehicle_id -- Provider 
            left join hd_delivery_dispatch_raw_prod_spec.provider on hd_delivery_tms_raw_prod_spec.driver.provider_id = hd_delivery_dispatch_raw_prod_spec.provider.id -- Event Date
            left join (
                select
                    te.external_system_order_id,
                    te."event-date",
                    ps.description
                from
                    hd_delivery_tracking_raw_prod.tracking_event te
                    left join hd_delivery_tracking_raw_prod_spec.pack_status ps on te.pack_status_id = ps.id
                where
                    te.id in (
                        select
                            max(te0.id) as id0
                        from
                            hd_delivery_tracking_raw_prod.tracking_event te0
                        group by
                            te0.external_system_order_id
                    )
            ) as tmp_te on dispatch_order.external_system_order_id = tmp_te.external_system_order_id -- Bultos
            --left join 
            --(select *,
            --case
            --when tmp_tags.total>0 and tmp_tags.total<=5 then 'MP'
            --when tmp_tags.total>5 and tmp_tags.total<=12 then 'P'
            --when tmp_tags.total>12 and tmp_tags.total<=20 then 'M'
            --when tmp_tags.total>20 then 'G'
            --else ''
            --end 
            --as size
            --from (
            --select
            --id,
            --created_at,
            --updated_at,
            --name,
            --value,
            --dispatch_order_id,
            --REGEXP_COUNT(value, '"quantity":1')+REGEXP_COUNT(value, '"quantity":2')*2+REGEXP_COUNT(value, '"quantity":3')*3+REGEXP_COUNT(value, '"quantity":4')*4+REGEXP_COUNT(value, '"quantity":5')*5+
            --REGEXP_COUNT(value, '"quantity":6')*6+REGEXP_COUNT(value, '"quantity":7')*7+REGEXP_COUNT(value, '"quantity":8')*8+REGEXP_COUNT(value, '"quantity":9')*9+REGEXP_COUNT(value, '"quantity":10')*10+
            --REGEXP_COUNT(value, '"quantity":11')*11+REGEXP_COUNT(value, '"quantity":12')*12+REGEXP_COUNT(value, '"quantity":13')*13+REGEXP_COUNT(value, '"quantity":14')*14+REGEXP_COUNT(value, '"quantity":15')*15
            --as total
            --from
            --hd_delivery_dispatch_raw_prod."tag"
            --where 1=1
            --and hd_delivery_dispatch_raw_prod."tag".name='items'
            --) as tmp_tags
            --) as tags_bultos
            --on dispatch_order.id = tags_bultos.dispatch_order_id
            left join (
                select
                    dispatch_order_id,
                    name,
                    value,
                    id
                from
                    hd_delivery_dispatch_raw_prod."tag"
                where
                    1 = 1
                    and (
                        lower(hd_delivery_dispatch_raw_prod."tag".name) like '%transportes%'
                    ) --and dispatch_order_id = 15258246
                    --group by dispatch_order_id,name,value
                    and hd_delivery_dispatch_raw_prod."tag".id in (
                        select
                            aux0.maxid
                        from
(
                                select
                                    dispatch_order_id,
                                    name,
                                    max (id) as maxid
                                from
                                    hd_delivery_dispatch_raw_prod."tag"
                                where
                                    1 = 1 --and dispatch_order_id = 14496340
                                    and (
                                        lower(hd_delivery_dispatch_raw_prod."tag".name) like '%transportes%'
                                    )
                                group by
                                    dispatch_order_id,
                                    name
                            ) as aux0
                    )
            ) as tags1 on dispatch_order.id = tags1.dispatch_order_id
            left join (
                select
                    dispatch_order_id,
                    name,
                    value,
                    id
                from
                    hd_delivery_dispatch_raw_prod."tag"
                where
                    1 = 1
                    and (
                        hd_delivery_dispatch_raw_prod."tag".name = 'truck_identifier'
                    ) --and dispatch_order_id = 15258246
                    --group by dispatch_order_id,name,value
                    and hd_delivery_dispatch_raw_prod."tag".id in (
                        select
                            aux1.maxid
                        from
(
                                select
                                    dispatch_order_id,
                                    name,
                                    max (id) as maxid
                                from
                                    hd_delivery_dispatch_raw_prod."tag"
                                where
                                    1 = 1 --and dispatch_order_id = 14496340
                                    and (
                                        hd_delivery_dispatch_raw_prod."tag".name = 'truck_identifier'
                                    )
                                group by
                                    dispatch_order_id,
                                    name
                            ) as aux1
                    )
            ) as tags2 on dispatch_order.id = tags2.dispatch_order_id
            left join hd_delivery_dispatch_raw_prod.vehicle_driver on hd_delivery_dispatch_raw_prod.vehicle_driver.id = hd_delivery_dispatch_raw_prod.dispatch_order.vehicle_driver_id
        where
            1 = 1
            and dispatch_order.retail_chain_id in (1, 4, 9)
            and pack2.last_status_code not in ('10', '1002')
            and pack2.last_status_code in ('09', '02', '04', '03')
        group by
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17 --[[and {{created_at}}]]
            --[[and {{update_at}}]]
            --[[and {{nombre_tienda}}]]
            --[[and {{codigo_tienda}}]]
            --[[and {{orden_compra}}]]
            --[[and {{estado}}]]
            --[[and {{subestado}}]]
            --[[and {{patente}}]]
            --[[and {{nombre_conductor}}]]
            --[[and {{negocio}}]]
            --[[and {{courier}}]]
    ) as tmp
where
    1 = 1
    and tmp.order_key in (
        select
            tmp000.order_key
        from
(
                select
                    dispatch_order.external_system_order_id,
                    dispatch_order.external_system_order_id || '|' || max(dispatch_order.updated_at :: timestamp) as order_key
                from
                    hd_delivery_dispatch_raw_prod.dispatch_order --where dispatch_order.external_system_order_id = 'v500140173spid-01'
                group by
                    1
            ) as tmp000
    )
    and tmp.negocio = '{negocio}'
    and tmp.proveedor <> 'None'
    and tmp.nombre_driver <> 'None' --and tmp.fecha_evento >= '2023-12-01 0:00:00'
    and tmp.fecha_compromiso >= '{fecha_compromiso_inicial}'
    and tmp.fecha_compromiso <= '{fecha_compromiso_final}' --[[and  tmp.fecha_evento>= ({{updated_at1}}::date || ' 0:00:00')::timestamp]]
    --[[and  tmp.fecha_evento<= ({{updated_at2}}::date || ' 23:59:59')::timestamp]]
    --[[and  tmp.fecha_compromiso>= ({{eta_1}}::date || ' 0:00:00')::timestamp]]
    --[[and  tmp.fecha_compromiso<= ({{eta_2}}::date || ' 23:59:59')::timestamp]]
    --[[and tmp.proveedor = {{proveedor}}]]