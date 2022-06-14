/*
 
Data cleaning using Sql in the nashvilleHousing dataset

*/

select * 
from portfolioproject..nashvilleHousing
order by parcelid


--1) Standardizing Date format in the data


--a)
update nashvilleHousing
set saledate = convert(date, saledate)
 
 --OR

--b)
alter table nashvilleHousing
add saleDateUpdated date;
update nashvilleHousing
set saleDateUpdated = convert(date, saledate)



--2) populate property address data(data where address is null).

select PropertyAddress
from portfolioproject..nashvilleHousing
where PropertyAddress is null

/*

finding the best replacement for the propertyaddress which has null value and 
populate that data with the data having unique parcelid and propertyaddress.

*/

select a.parcelid, a.PropertyAddress, b.parcelid, b.propertyaddress, isnull(b.PropertyAddress,a.PropertyAddress)
from portfolioproject..nashvilleHousing a
join portfolioproject..nashvilleHousing b 
on a.parcelid=b.parcelid and
a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

update a
set PropertyAddress = isnull(b.PropertyAddress,a.PropertyAddress)
from portfolioproject..nashvilleHousing a
join portfolioproject..nashvilleHousing b 
on a.parcelid=b.parcelid and
a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null


-- breaking address column int individual columns (address, city, state)
-- method 1 out of 2

select PropertyAddress
from portfolioproject..nashvilleHousing

select SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)-1), 
SUBSTRING(propertyaddress,  charindex(',', propertyaddress)+1, len(propertyaddress))
from portfolioproject..nashvilleHousing

alter table nashvilleHousing
add address1 nvarchar(255), address2 nvarchar(255)

update nashvilleHousing
set address1 =SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)-1)
, address2=SUBSTRING(propertyaddress,  charindex(',', propertyaddress)+1, len(propertyaddress))

-- method 2 of 2

select 
PARSENAME(replace(owneraddress,',', '.'),3), 
PARSENAME(replace(owneraddress,',', '.'),2), 
PARSENAME(replace(owneraddress,',', '.'),1) 
from portfolioproject..nashvilleHousing

alter table nashvilleHousing
add split_address nvarchar(255), split_city nvarchar(255), split_state nvarchar(255)

update nashvilleHousing
set split_address=PARSENAME(replace(owneraddress,',', '.'),3), 
split_city = PARSENAME(replace(owneraddress,',', '.'),2), 
split_state=PARSENAME(replace(owneraddress,',', '.'),1)

 
--Changing 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant column

select distinct soldasvacant, count(soldasvacant) as count
from portfolioproject..nashvilleHousing
group by soldasvacant
order by 2

select soldasvacant, 
case 
    when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end
from portfolioproject..nashvilleHousing

update nashvilleHousing
set soldasvacant = case 
    when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant
	end


--Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From portfolioproject..nashvilleHousing

)
--delete
select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- delete unused columns

select *
From portfolioproject..nashvilleHousing

alter table nashvilleHousing
drop column propertyaddress, saledate, owneraddress, taxdistrict
