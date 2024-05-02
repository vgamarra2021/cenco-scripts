select
    *
from
    (
        select
            --ExternalSystemOrderId
            dispatch_order.external_system_order_id as orden_compra,
            --Courier
            hd_delivery_dispatch_raw_prod_spec.courier.name as sistema,
            --ExternalDriverId
            hd_delivery_dispatch_raw_prod.dispatch_order.external_driver_id as codigo_conductor,
            --Codigo País
            hd_delivery_dispatch_raw_prod_spec.country.code as codigo_pais,
            --Courier
            case
                when sistema = 'Beetrack' then tags1.value --Tags1 Table
                when sistema = 'Home Delivery Chile' then provider.name --Provider Table
                else sistema --Courier
            end as proveedor,
            --LicencePlate
            case
                when sistema = 'Beetrack' then tags2.value --Tags2 Table
                when sistema = 'Home Delivery Chile' then hd_delivery_tms_raw_prod_spec.vehicle.licence_plate --Vehicle Licence Plate
                else sistema --Courier
            end as patente,
            --driverName
            case
                when sistema = 'Beetrack' then hd_delivery_dispatch_raw_prod.vehicle_driver.full_name --driverName from VehicleDriver
                else hd_delivery_tms_raw_prod_spec.driver.full_name --driverName from driver
            end as nombre_driver,
            --RetailChainName
            retail_chain.name as negocio,
            --StoreCode
            known_source.external_id as codigo_tienda,
            --StoreName
            known_source.name as nombre_tienda,
            --EventDate from TrackingEvents BD
            tmp_te."event-date" :: timestamp as fecha_evento,
            --CommitmentDate
            case
                when codigo_pais = 'PE' then date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-5'
                )
                when codigo_pais = 'CO' then date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-5'
                )
                when codigo_pais = 'AR' then date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-3'
                )
                when codigo_pais = 'BR' then date(
                    dispatch_order.eta_end_date :: timestamp AT TIME ZONE 'UTC-3'
                )
                else date(dispatch_order.eta_end_date :: timestamp)
            end as fecha_compromiso,
            --LastStatusDesc
            pack2.last_status_desc as nombre_estado,
            --LastSubStatusDesc
            pack2.last_sub_status_desc as nombre_sub_estado,
            --SubAdminZone2 Name
            saz2_destination.name as comuna_destino,
            --DestinationLatitude
            destination.latitude as latitude,
            --DestinationLogitude
            destination.longitude as longitude,
            --OnTime
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
                    DATE_TRUNC('minute', tmp_te."event-date" :: timestamp) <= DATE_TRUNC(
                        'minute',
                        dispatch_order.eta_end_date :: timestamp
                    )
                ) then 1
                else 0
            end as on_time,
            --OrderKey
            dispatch_order.external_system_order_id || '|' || max(dispatch_order.updated_at :: timestamp) as order_key
        from
            --DispatchOrder
            hd_delivery_dispatch_raw_prod.dispatch_order
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
            ) as pack2 on pack2.dispatch_order_id = dispatch_order.id --TODO
            left join hd_delivery_dispatch_raw_prod.destination on destination.id = dispatch_order.destination_id --Destination
            left join hd_delivery_dispatch_raw_prod_spec.sub_admin_zone_1 saz1_destination on saz1_destination.id = destination.sub_admin_zone_1_id --SubAdminZone1 Destination
            left join hd_delivery_dispatch_raw_prod_spec.sub_admin_zone_2 saz2_destination on saz2_destination.id = destination.sub_admin_zone_2_id --SubAdminZone2 Destination
            left join hd_delivery_dispatch_raw_prod_spec.known_source on known_source.id = dispatch_order.owner_known_source_id --Known Source
            left join hd_delivery_dispatch_raw_prod_spec.retail_chain on hd_delivery_dispatch_raw_prod_spec.retail_chain.id = hd_delivery_dispatch_raw_prod.dispatch_order.retail_chain_id --Retail chain
            left join hd_delivery_dispatch_raw_prod_spec.country on hd_delivery_dispatch_raw_prod_spec.country.id = hd_delivery_dispatch_raw_prod_spec.retail_chain.country_id --Country
            left join hd_delivery_dispatch_raw_prod_spec.dispatch_type on hd_delivery_dispatch_raw_prod.dispatch_order.dispatch_type_id = hd_delivery_dispatch_raw_prod_spec.dispatch_type.id --Dispatch Type
            left join hd_delivery_dispatch_raw_prod_spec.courier on hd_delivery_dispatch_raw_prod_spec.courier.id = hd_delivery_dispatch_raw_prod.dispatch_order.courier_id --Courier
            left join hd_delivery_tms_raw_prod_spec.driver on hd_delivery_tms_raw_prod_spec.driver.id = hd_delivery_dispatch_raw_prod.dispatch_order.external_driver_id --Driver TMS
            left join hd_delivery_tms_raw_prod_spec.vehicle on hd_delivery_tms_raw_prod_spec.vehicle.id = hd_delivery_tms_raw_prod_spec.driver.vehicle_id --Vehicle TMS
            left join hd_delivery_dispatch_raw_prod_spec.provider on hd_delivery_tms_raw_prod_spec.driver.provider_id = hd_delivery_dispatch_raw_prod_spec.provider.id --Provider from TMS
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
            ) as tmp_te on dispatch_order.external_system_order_id = tmp_te.external_system_order_id -- Tracking Events, LastStatus
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
            ) as tags1 on dispatch_order.id = tags1.dispatch_order_id --Tags
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
            ) as tags2 on dispatch_order.id = tags2.dispatch_order_id --Tags2
            left join hd_delivery_dispatch_raw_prod.vehicle_driver on hd_delivery_dispatch_raw_prod.vehicle_driver.id = hd_delivery_dispatch_raw_prod.dispatch_order.vehicle_driver_id --VehicleDriver
        where
            1 = 1
            and dispatch_order.retail_chain_id in (1, 4, 9) --RetailChainId
            and pack2.last_status_code not in ('10', '1002') --LastStatusCode
            and pack2.last_status_code in ('09', '02', '04', '03') --LastStatusCode
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
            17,
            18 --[[and {{created_at}}]]
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
    and tmp.orden_compra = 'v121932843jmch-01'
    and tmp.negocio = '{negocio}'
    and tmp.proveedor <> 'None'
    and tmp.nombre_driver <> 'None'
    and tmp.fecha_compromiso >= '{fecha_compromiso_inicial}'
    and tmp.fecha_compromiso <= '{fecha_compromiso_final}' --[[and  tmp.fecha_evento>= ({{updated_at1}}::date || ' 0:00:00')::timestamp]]
    --[[and  tmp.fecha_evento<= ({{updated_at2}}::date || ' 23:59:59')::timestamp]]
    --[[and  tmp.fecha_compromiso>= ({{eta_1}}::date || ' 0:00:00')::timestamp]]
    --[[and  tmp.fecha_compromiso<= ({{eta_2}}::date || ' 23:59:59')::timestamp]]
    --[[and tmp.proveedor = {{proveedor}}]]