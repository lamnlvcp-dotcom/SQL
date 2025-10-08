-- Create table
-- Create table test_db.dbo.warehouse_phieu_xuat_nhap
-- (entity NVARCHAR(450)
--,id NVARCHAR(450)
--,branch_code NVARCHAR(450)
--,fiscal_year Float
--,stt NVARCHAR(450)
--,row_id NVARCHAR(450)
--,doc_code NVARCHAR(450)
--,ten_ct NVARCHAR(450)
--,doc_group FLOAT
--,doc_date DATETIME
--,doc_no NVARCHAR(450)
--,atch_doc_no NVARCHAR(450)
--,description NVARCHAR(2000)
--,warehouse_code NVARCHAR(450)
--,item_lot_code NVARCHAR(450)
--,receipt_warehouse_code NVARCHAR(450)
--,item_code NVARCHAR(450)
--,unit NVARCHAR(450)
--,quantity FLOAT
--,amount FLOAT
--,biz_doc_id NVARCHAR(450)
--,territory_code FLOAT
--,customer_code NVARCHAR(450)
--,customer_name NVARCHAR(450)
--,city_name NVARCHAR(450)
--,city_name_2 NVARCHAR(450)
--,is_active FLOAT
--,update_time DATETIME
--,item_name
--,unit_cost -- là giá mua trước vat, bảng sl
--,tax_amount 
--,total_amount_before_tax 
--,total_amount_after_tax
--,expiry_date
--,atch_doc_serial_no
--,code_old
--,quantity_unit_smallest
--,unit_smallest

--)
--;



--Truncate table test_db.dbo.warehouse_phieu_xuat_nhap;
-- Insert into test_db.dbo.warehouse_phieu_xuat_nhap

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Phieu xuat nhap va cac chung tu khac
-- entity: vcp

Select *

from
(SELECT 'vcp' as entity
,sl.Id as id
,sl.BranchCode as branch_code
,sl.FiscalYear as fiscal_year
,sl.Stt as stt
,sl.RowId as row_id
--,sl.EntryNo as entry_no
,sl.DocCode as doc_code
,v_dmct.Ten_Ct as ten_ct
,sl.DocGroup as doc_group
,sl.DocDate as doc_date
,ct.DocNo as doc_no
,adad.AtchDocNo as atch_doc_no
,sl.Description as description
,sl.WarehouseCode as warehouse_code
,sl.ItemLotCode as item_lot_code
,sl.ReceiptWarehouseCode as receipt_warehouse_code
,sl.ItemCode as item_code
,sl.Unit as unit
,coalesce(adp.Quantity9,adpr.Quantity9,ads.Quantity9,adsr.Quantity9,adi.Quantity9) as quantity -- bang adp quantity 9 la theo unit hoa don - co the la vien hay hop, quantity la theo unit nho nhat
--,sl.Quantity as quantity
--,sl.UnitCost as unit_cost
--,sl.OriginalUnitCost as original_unit_cost
,sl.Amount as amount
--,sl.OriginalAmount as original_amount
--,sl.UnitPrice as unit_price
--,sl.OriginalUnitPrice as original_unit_price
--,sl.Amount2 as amount_2
--,sl.OriginalAmount2 as original_amount_2
,sl.BizDocId_C2 as biz_doc_id
,sl.TerritoryCode as territory_code
,sl.CustomerCode as customer_code
,v_customer.Name as customer_name
,v_city.Name as city_name
,case when isnull(v_city.Name2,'') = '' then v_city.Name else v_city.Name2 end as city_name_2
--,sl.UniqueId as unique_id
,sl.IsActive as is_active
,getdate() as update_time
,item.Name as item_name
,il.ExpiryDate as expiry_date
,adad.AtchDocSerialNo as atch_doc_serial_no
,item.CodeOld as code_old
,coalesce(adp.Quantity,adpr.Quantity,ads.Quantity,adsr.Quantity,adi.Quantity) as quantity_unit_smallest
,item.Unit as unit_smallest

-- unit cost
,coalesce(adp.UnitCost,adpr.UnitCost) as unit_cost
-- amount_gia_mua_before_tax
,coalesce(adp.Amount,adpr.Amount) as amount_gia_mua_before_tax
-- amount gia mua tax
,coalesce(adp.Amount3,adpr.Amount3) as amount_gia_mua_tax
-- amount_gia_mua_after_tax
,coalesce(adp.Amount,adpr.Amount) + coalesce(adp.Amount3,adpr.Amount3) as amount_gia_mua_after_tax

-- unit price
,coalesce(ads.UnitPrice,adsr.UnitPrice) as unit_price
-- amount_gia_ban_before_tax
,coalesce(ads.Amount2,adsr.Amount2) as amount_gia_ban_before_tax
-- amount gia ban tax
,coalesce(ads.Amount3,adsr.Amount3) as amount_gia_ban_tax
-- amount_gia_ban_after_tax
,coalesce(ads.Amount2,adsr.Amount2) + coalesce(ads.Amount3,adsr.Amount3)  as amount_gia_ban_after_tax


FROM B7R2_VCP_TH.dbo.B30StockLedger sl 
	LEFT JOIN B7R2_VCP_TH.dbo.B30AccDoc ct ON sl.Stt = ct.Stt
	Left join B7R2_VCP_TH.dbo.B30AccDocAtchDoc adad on adad.Stt = sl.Stt
	left join B7R2_VCP_TH.dbo.B00DmCt v_dmct on sl.DocCode = v_dmct.Ma_Ct
	left join B7R2_VCP_TH.dbo.B20Customer v_customer on v_customer.Code = sl.CustomerCode
	left join B7R2_VCP_TH.dbo.B20Territory v_city on v_city.Code = sl.TerritoryCode
	left join B7R2_VCP_TH.dbo.B20Item item on sl.ItemCode = item.Code
	left join B7R2_VCP_TH.dbo.B20ItemLot il on il.ItemCode = sl.ItemCode and il.Code = sl.ItemLotCode
	left join B7R2_VCP_TH.dbo.B30AccDocPurchase adp on adp.Stt = sl.Stt and adp.RowId = sl.RowId
	left join B7R2_VCP_TH.dbo.B30AccDocPurchaseReturn adpr on adpr.Stt = sl.Stt and adpr.RowId = sl.RowId
	left join B7R2_VCP_TH.dbo.B30AccDocSales ads on ads.Stt = sl.Stt and ads.RowId = sl.RowId
	left join B7R2_VCP_TH.dbo.B30AccDocSalesReturn adsr on adsr.Stt = sl.Stt and adsr.RowId = sl.RowId
	left join B7R2_VCP_TH.dbo.B30AccDocInventory adi on adi.Stt = sl.Stt and adi.RowId = sl.RowId

	)base

where 1=1
and base.is_active = 1




UNION


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Phieu xuat nhap va cac chung tu khac
-- entity: salud

Select *
from
(SELECT 'salud' as entity
,sl.Id as id
,sl.BranchCode as branch_code
,sl.FiscalYear as fiscal_year
,sl.Stt as stt
,sl.RowId as row_id
--,sl.EntryNo as entry_no
,sl.DocCode as doc_code
,v_dmct.Ten_Ct as ten_ct
,sl.DocGroup as doc_group
,sl.DocDate as doc_date
,ct.DocNo as doc_no
,adad.AtchDocNo as atch_doc_no
,sl.Description as description
,sl.WarehouseCode as warehouse_code
,sl.ItemLotCode as item_lot_code
,sl.ReceiptWarehouseCode as receipt_warehouse_code
,sl.ItemCode as item_code
,sl.Unit as unit
,coalesce(adp.Quantity9,adpr.Quantity9,ads.Quantity9,adsr.Quantity9,adi.Quantity9) as quantity -- bang adp quantity 9 la theo unit hoa don - co the la vien hay hop, quantity la theo unit nho nhat
--,sl.Quantity as quantity
--,sl.UnitCost as unit_cost
--,sl.OriginalUnitCost as original_unit_cost
,sl.Amount as amount
--,sl.OriginalAmount as original_amount
--,sl.UnitPrice as unit_price
--,sl.OriginalUnitPrice as original_unit_price
--,sl.Amount2 as amount_2
--,sl.OriginalAmount2 as original_amount_2
,sl.BizDocId_C2 as biz_doc_id
,sl.TerritoryCode as territory_code
,sl.CustomerCode as customer_code
,v_customer.Name as customer_name
,v_city.Name as city_name
,case when isnull(v_city.Name2,'') = '' then v_city.Name else v_city.Name2 end as city_name_2
--,sl.UniqueId as unique_id
,sl.IsActive as is_active
,getdate() as update_time
,item.Name as item_name

,il.ExpiryDate as expiry_date
,adad.AtchDocSerialNo as atch_doc_serial_no
,item.CodeOld as code_old
,coalesce(adp.Quantity,adpr.Quantity,ads.Quantity,adsr.Quantity,adi.Quantity) as quantity_unit_smallest
,item.Unit as unit_smallest

-- unit cost
,coalesce(adp.UnitCost,adpr.UnitCost) as unit_cost
-- amount_gia_mua_before_tax
,coalesce(adp.Amount,adpr.Amount) as amount_gia_mua_before_tax
-- amount gia mua tax
,coalesce(adp.Amount3,adpr.Amount3) as amount_gia_mua_tax
-- amount_gia_mua_after_tax
,coalesce(adp.Amount,adpr.Amount) + coalesce(adp.Amount3,adpr.Amount3) as amount_gia_mua_after_tax

-- unit price
,coalesce(ads.UnitPrice,adsr.UnitPrice) as unit_price
-- amount_gia_ban_before_tax
,coalesce(ads.Amount2,adsr.Amount2) as amount_gia_ban_before_tax
-- amount gia ban tax
,coalesce(ads.Amount3,adsr.Amount3) as amount_gia_ban_tax
-- amount_gia_ban_after_tax
,coalesce(ads.Amount2,adsr.Amount2) + coalesce(ads.Amount3,adsr.Amount3)  as amount_gia_ban_after_tax


FROM B7R2_SALUD_TH.dbo.B30StockLedger sl 
	LEFT JOIN B7R2_SALUD_TH.dbo.B30AccDoc ct ON sl.Stt = ct.Stt
	Left join B7R2_SALUD_TH.dbo.B30AccDocAtchDoc adad on adad.Stt = sl.Stt
	left join B7R2_SALUD_TH.dbo.B00DmCt v_dmct on sl.DocCode = v_dmct.Ma_Ct
	left join B7R2_SALUD_TH.dbo.B20Customer v_customer on v_customer.Code = sl.CustomerCode
	left join B7R2_SALUD_TH.dbo.B20Territory v_city on v_city.Code = sl.TerritoryCode
	left join B7R2_SALUD_TH.dbo.B20Item item on sl.ItemCode = item.Code
	left join B7R2_SALUD_TH.dbo.B20ItemLot il on il.ItemCode = sl.ItemCode and il.Code = sl.ItemLotCode
	left join B7R2_SALUD_TH.dbo.B30AccDocPurchase adp on adp.Stt = sl.Stt and adp.RowId = sl.RowId
	left join B7R2_SALUD_TH.dbo.B30AccDocPurchaseReturn adpr on adpr.Stt = sl.Stt and adpr.RowId = sl.RowId
	left join B7R2_SALUD_TH.dbo.B30AccDocSales ads on ads.Stt = sl.Stt and ads.RowId = sl.RowId
	left join B7R2_SALUD_TH.dbo.B30AccDocSalesReturn adsr on adsr.Stt = sl.Stt and adsr.RowId = sl.RowId
	left join B7R2_SALUD_TH.dbo.B30AccDocInventory adi on adi.Stt = sl.Stt and adi.RowId = sl.RowId
	
	)base

where 1=1
and base.is_active = 1
--and base.doc_no = 'NM/25/01125'
-- and base.stt = 'A010000000001343'


UNION

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Phieu xuat nhap va cac chung tu khac
-- entity: nufa


Select *

from
(Select 'nufa' as entity
,sl.Id as id
,sl.BranchCode as branch_code
,sl.FiscalYear as fiscal_year
,sl.Stt as stt
,sl.RowId as row_id
--,sl.EntryNo as entry_no
,sl.DocCode as doc_code
,nufa_dmct.Ten_Ct as ten_ct
,sl.DocGroup as doc_group -- 1 la nhap, 2 la xuat
,sl.DocDate as doc_date
,sl.DocNo as doc_no
,adad.AtchDocNo as atch_doc_no
,sl.Description as description
,nufa_wh.Code as warehouse_code
,adip.ItemLotCode as item_lot_code
,nufa_wh_re.Code as receipt_warehouse_code
,nufa_item.Code as item_code
,sl.Unit as unit
,coalesce(adp1.Quantity9,adi.Quantity9,ads1.Quantity9,ads2.Quantity9) as quantity -- bang adp quantity 9 la theo unit hoa don - co the la vien hay hop, quantity la theo unit nho nhat
--,sl.Quantity as quantity
--,sl.UnitCost as unit_cost
--,sl.OriginalUnitCost as original_unit_cost
,sl.Amount as amount
--,sl.OriginalAmount as original_amount
--,sl.UnitPrice as unit_price
--,sl.OriginalUnitPrice as original_unit_price
--,sl.Amount2 as amount_2
--,sl.OriginalAmount2 as original_amount_2
,sl.BizDocId_SO as biz_doc_id
,sl.TerritoryCode as territory_code
,nufa_customer.Code as customer_code
,nufa_customer.Name as customer_name
,nufa_city.Name as city_name
,case when isnull(nufa_city.Name2,'') = '' then nufa_city.Name else nufa_city.Name2 end as city_name_2
--,sl.UniqueId as unique_id
,sl.IsActive as is_active
,getdate() as update_time
,nufa_item.Name as item_name
--,sl.UnitCost as unit_cost -- là giá mua trước vat, bảng sl
,coalesce(adp1.UnitCost,adi.UnitCost,ads1.UnitCost,ads2.UnitCost) as unit_cost -- là giá mua trước vat, bảng sl. Unit cost này theo quantity của bảng
-- ,sl.UnitPrice
,coalesce(adp1.Amount3,adi.Amount3,ads1.Amount3,ads2.Amount3) as tax_amount -- HD: giá bán, NM: giá mua
,coalesce(adp1.Amount,adi.Amount,ads1.Amount,ads2.Amount) as total_amount_before_tax -- HD: giá bán, NM: giá mua
,isnull(coalesce(adp1.Amount3,adi.Amount3,ads1.Amount3,ads2.Amount3),0) + isnull(coalesce(adp1.Amount,adi.Amount,ads1.Amount,ads2.Amount),0) as total_amount_after_tax
,ild.ExpiryDate as expiry_date
,adad.AtchDocSerialNo as atch_doc_serial_no
,nufa_item.CodeOld as code_old
,coalesce(adp1.Quantity,adi.Quantity,ads1.Quantity,ads2.Quantity) as quantity_unit_smallest
,nufa_item.Unit as unit_smallest


 from B8R3_NUFAMED_Data.dbo.B30StockLedger sl	
	-- left join B8R3_NUFAMED_Data.dbo.B30StockLedgerPhys slp on sl.RowId = slp.RowId -- sl.RowId = slp.RowId  sl.UniqueId = slp.UniqueId
	left join B8R3_NUFAMED.dbo.B00DmCt nufa_dmct on sl.DocCode = nufa_dmct.Ma_Ct
	--left join B8R3_NUFAMED_Data.dbo.B30AccDocSales nufa_ads on sl.Stt = nufa_ads.Stt
	--left join B8R3_NUFAMED_Data.dbo.B30AccDocPurchase nufa_adp on sl.Stt = nufa_adp.Stt
	--left join B8R3_NUFAMED_Data.dbo.B30AccDocItem nufa_adi on sl.Stt = nufa_adi.Stt
	left join B8R3_NUFAMED_Data.dbo.B20Warehouse nufa_wh on nufa_wh.Id = sl.WarehouseId
	left join B8R3_NUFAMED_Data.dbo.B20Warehouse nufa_wh_re on nufa_wh_re.Id = sl.ReceiptWarehouseId
	left join B8R3_NUFAMED_Data.dbo.B20Item nufa_item on nufa_item.Id = sl.ItemId
	left join B8R3_NUFAMED_Data.dbo.B20Customer nufa_customer on nufa_customer.Id = sl.CustomerId
	left join B8R3_NUFAMED_Data.dbo.B20Territory nufa_city on nufa_city.Code = sl.TerritoryCode
	left join B8R3_NUFAMED_Data.dbo.B30AccDocPurchase1 adp1 on adp1.Stt = sl.Stt and adp1.ItemId = sl.ItemId and adp1.RowId = sl.RowId
	left join B8R3_NUFAMED_Data.dbo.B30AccDocItem3 adi on adi.Stt = sl.Stt and adi.ItemId = sl.ItemId and adi.RowId = sl.RowId
	left join B8R3_NUFAMED_Data.dbo.B30AccDocSales1 ads1 on ads1.Stt = sl.Stt and ads1.ItemId = sl.ItemId and ads1.RowId = sl.RowId	
	left join B8R3_NUFAMED_Data.dbo.B30AccDocSales2 ads2 on ads2.Stt = sl.Stt and ads2.ItemId = sl.ItemId and ads2.RowId = sl.RowId	

	left join (Select adip.Stt
					,adip.RowId_SourceDoc
					--,adip.RowId
					,adip.ItemId
					,adip.ItemLotCode
					,adip.DocGroup
					
					from B8R3_NUFAMED_Data.dbo.B30AccDocInventoryPhys adip

					where 1=1
					and adip.IsActive = 1
				--	and adip.Stt = '00000807'
					--and adip.RowId_SourceDoc = '00004395HD'
					--and adip.DocGroup = 2

					GROUP BY adip.Stt
					,adip.RowId_SourceDoc
					--,adip.RowId
					,adip.ItemId
					,adip.ItemLotCode
					,adip.DocGroup

				)adip on adip.Stt = sl.Stt and adip.RowId_SourceDoc = sl.RowId and adip.ItemId = sl.ItemId -- and adip.DocGroup = sl.DocGroup
	
	left join (Select base.Stt
				,base.DocCode
				,base.AtchDocNo
				,base.AtchDocSerialNo

				from
				(SELECT *
				,Case when DocCode = 'CP' then 0
					  when DocCode = 'NM' and ISNULL(TaxCode,'') = '' then 0
					  else 1 end as is_filter
  	

				  FROM [B8R3_NUFAMED_Data].[dbo].[B30AccDocAtchDoc]
				  where IsActive = 1
				  and ISNULL(RowId_SourceDoc, '') = ''
				  and AtchDocSerialNo <> ''
  

				)base

				where 1=1
				and base.is_filter = 1

				GROUP BY base.Stt
				,base.DocCode
				,base.AtchDocNo
				,base.AtchDocSerialNo

			)adad on adad.Stt = sl.Stt and adad.DocCode = sl.DocCode

	left join B8R3_NUFAMED_Data.dbo.B20ItemLotDetail ild on ild.ItemLotCode = adip.ItemLotCode and ild.ItemId = sl.ItemId


				

)base

	where 1=1
	and base.is_active = 1
--	and base.stt = '00004169'
--	and base.atch_doc_no = N'C25TNF104'
--	and base.item_code = 'D0019'
-- and base.doc_no = 'NM01/25-0003'
--	and base.doc_no = 'NM08/25-0001'




UNION

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Phieu xuat nhap va cac chung tu khac
-- entity: durabe

Select *

from
(Select 'durabe' as entity
,slp.Id as id
,slp.BranchCode as branch_code
,slp.FiscalYear as fiscal_year
,slp.Stt as stt
,slp.RowId as row_id
,slp.DocCode as doc_code
,ct.Ten_Ct as ten_ct
,slp.DocGroup as doc_group
,slp.DocDate as doc_date
,coalesce(ads.DocNo,adp.DocNo,adi.DocNo) as doc_no
,coalesce(adas.AtchDocNo,adap.AtchDocNo) as atch_doc_no
,coalesce(ads.Description,adp.Description,adi.Description) as description
,wh.Code as warehouse_code
,slp.ItemLotCode as item_lot_code
,wh_re.Code as receipt_warehouse_code
,item.Code as item_code
,slp.Unit as unit
,coalesce(adp1.Quantity9,ads1.Quantity9,adi2.Quantity9,adi3.Quantity9,slp.Quantity9) as quantity -- bang adp quantity 9 la theo unit hoa don - co the la vien hay hop, quantity la theo unit nho nhat
--,slp.Quantity as quantity
--,coalesce(ads.CustomerId,adp.CustomerId,adi.CustomerId) as customer_id
,coalesce(ads.TotalAmount,adp.TotalAmount,adi.TotalAmount) as amount
,coalesce(ads.BizDocId_SO,adp.BizDocId_SO,adi.BizDocId_SO) as biz_doc_id
,te.Code as territory_code
,cus.Code as customer_code
,cus.Name as customer_name
,te.Name as city_name 
,case when isnull(te.Name2,'') = '' then te.Name else te.Name2 end as city_name_2
,slp.IsActive as is_active
,getdate() as update_time
,item.Name as item_name
,coalesce(adp1.UnitCost,ads1.UnitCost,adi2.UnitCost,adi3.UnitCost) as unit_cost -- là giá mua trước vat, bảng sl. Unit cost này theo quantity của bảng
,coalesce(adp1.Amount3,ads1.Amount3,adi2.Amount3,adi3.Amount3) as tax_amount -- HD: giá bán, NM: giá mua
,coalesce(adp1.Amount,ads1.Amount,adi2.Amount,adi3.Amount) as total_amount_before_tax -- HD: giá bán, NM: giá mua
,isnull(coalesce(adp1.Amount3,ads1.Amount3,adi2.Amount3,adi3.Amount3),0) + isnull(coalesce(adp1.Amount,ads1.Amount,adi2.Amount,adi3.Amount),0) as total_amount_after_tax
,ild.ExpiryDate as expiry_date
,coalesce(adas.AtchDocSerialNo ,adap.AtchDocSerialNo) as atch_doc_serial_no
,item.CodeOld as code_old
,coalesce(adp1.Quantity,ads1.Quantity,adi2.Quantity,adi3.Quantity,slp.Quantity) as quantity_unit_smallest
,item.Unit as unit_smallest




from Rep_Durabe2.dbo.B30StockLedgerPhys slp
	left join Rep_Durabe.dbo.B00DmCt ct on slp.DocCode = ct.Ma_Ct
	left join Rep_Durabe2.dbo.B30AccDocAtchSales adas on adas.Stt = slp.Stt and adas.DocCode = slp.DocCode and adas.IsActive = 1 and adas.Posted = 1 and ISNULL(adas.TaxCode, '') <> ''
	left join Rep_Durabe2.dbo.B30AccDocAtchPurchase adap on adap.Stt = slp.Stt and adap.DocCode = slp.DocCode and adap.IsActive = 1 and adap.Posted = 1 and ISNULL(adap.TaxCode, '') <> ''
	left join Rep_Durabe2.dbo.B30AccDocSales ads on slp.Stt = ads.Stt and slp.DocCode = ads.DocCode and ads.IsActive = 1 and ads.Posted = 1
	left join Rep_Durabe2.dbo.B30AccDocPurchase adp on slp.Stt = adp.Stt and slp.DocCode = adp.DocCode and adp.IsActive = 1 and adp.Posted = 1
	left join Rep_Durabe2.dbo.B30AccDocItem adi on slp.Stt = adi.Stt and slp.DocCode = adi.DocCode and adi.IsActive = 1 and adi.Posted = 1 
	left join Rep_Durabe2.dbo.B30StockLedgerPhys slp_re on (slp.DocGroup = 2 and slp.IsActive = 1)
														and (slp_re.DocGroup = 1 and slp_re.IsActive = 1)
														and slp.Stt = slp_re.Stt
														and slp.RowId = slp_re.RowId
														and slp.ItemId = slp_re.ItemId
	left join Rep_Durabe2.dbo.B20Warehouse wh on wh.Id = slp.WarehouseId
	left join Rep_Durabe2.dbo.B20Warehouse wh_re on wh_re.Id = slp_re.WarehouseId
	left join Rep_Durabe2.dbo.B20Item item on item.Id = slp.ItemId
	left join Rep_Durabe2.dbo.B20Customer cus on cus.Id = coalesce(ads.CustomerId,adp.CustomerId,adi.CustomerId)
	left join Rep_Durabe2.dbo.B20Territory te on cus.TerritoryId = te.Id
	left join Rep_Durabe2.dbo.B30AccDocPurchase1 adp1 on adp1.Stt = slp.Stt and adp1.RowId = slp.RowId_SourceDoc
	left join Rep_Durabe2.dbo.B30AccDocSales1 ads1 on ads1.Stt = slp.Stt and ads1.RowId = slp.RowId_SourceDoc
	left join Rep_Durabe2.dbo.B30AccDocItem2 adi2 on adi2.Stt = slp.Stt and adi2.RowId = slp.RowId_SourceDoc
	left join Rep_Durabe2.dbo.B30AccDocItem3 adi3 on adi3.Stt = slp.Stt and adi3.RowId = slp.RowId_SourceDoc

	left join Rep_Durabe2.dbo.B20ItemLotDetail ild on ild.ItemId = slp.ItemId and ild.ItemLotCode = slp.ItemLotCode

)base

where 1=1
and base.is_active = 1
-- and base.doc_no = 'NM2501-0002'
-- and base.stt = '00036983'


