select * from datacleaning;

SET SQL_SAFE_UPDATES = 0;
#Standardize Date Format
Select SaleDate,CONVERT(SaleDate, Datetime)
From datacleaning;

Update datacleaning
SET SaleDate = CONVERT(SaleDate,Datetime);

#If it doesn't Update properly
ALTER TABLE datacleaning
Add SaleDateConverted Date;

Update datacleaning
SET SaleDateConverted = CONVERT(SaleDate,Datetime);

#Populate Property Address data
Select a.UniqueId,a.parcelID, a.PropertyAddress, b.UniqueID,b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)
From datacleaning a
left join datacleaning b 
	on a.ParcelID=b.ParcelID
    and a.UniqueID<> b.UniqueID
Where a.PropertyAddress is null;


Update datacleaning a left join datacleaning b 
		on a.ParcelID=b.ParcelID and a.UniqueID<> b.UniqueID
SET a.PropertyAddress = ifnull(a.PropertyAddress,b.PropertyAddress)
Where a.PropertyAddress is null;


#Breaking out Property Address into Individual Columns (Address, City, State)

Select PropertyAddress
From datacleaning
#Where PropertyAddress is null
#order by ParcelID
;

Select substring(PropertyAddress, 1, instr(PropertyAddress,',')-1) as Address,
substring(PropertyAddress, instr(PropertyAddress,',')+1,length(PropertyAddress)-instr(PropertyAddress,',')) as City
From datacleaning;

ALTER TABLE datacleaning
Add PropertySplitAddress Nvarchar(255);

Update datacleaning
SET PropertySplitAddress = substring(PropertyAddress, 1, instr(PropertyAddress,',')-1);

ALTER TABLE datacleaning
Add PropertySplitCity Nvarchar(255);

Update datacleaning
SET PropertySplitCity = substring(PropertyAddress, instr(PropertyAddress,',')+1,length(PropertyAddress)-instr(PropertyAddress,','));

#Breaking out Owner Address into Individual Columns (Address, City, State)
select OwnerAddress, 
left(OwnerAddress, instr(OwnerAddress,',')-1),
substring(OwnerAddress, instr(OwnerAddress,',')+2, instr(mid(OwnerAddress,instr(OwnerAddress,",")+2,length(OwnerAddress)),',')-1),
right(OwnerAddress,2)
from datacleaning;

ALTER TABLE datacleaning
Add OwnerSplitAddress Nvarchar(255);

Update datacleaning
SET OwnerSplitAddress = left(OwnerAddress, instr(OwnerAddress,',')-1);

ALTER TABLE datacleaning
Add OwnerSplitCity Nvarchar(255);

Update datacleaning
SET OwnerSplitCity = substring(OwnerAddress, instr(OwnerAddress,',')+2, instr(mid(OwnerAddress,instr(OwnerAddress,",")+2,length(OwnerAddress)),',')-1);

ALTER TABLE datacleaning
Add OwnerSplitState Nvarchar(255);

Update datacleaning
SET OwnerSplitState = right(OwnerAddress,2);

select * from datacleaning;

#Change Y and N to Yes and No in "Sold as Vacant" field
select distinct SoldAsVacant, count(SoldAsVacant) 
from datacleaning
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case 
	when SoldAsVacant='Y' then 'Yes'
    when SoldAsVacant='N' then 'No'
    else SoldAsVacant
end
from datacleaning;

update datacleaning
set SoldAsVacant = 
	case 
		when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		else SoldAsVacant
	end;

select distinct(SoldAsVacant) from datacleaning;

#find Duplicates
select * from datacleaning;

with cte as (
select *,
	row_number() over (
    partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
    order by UniqueID) as row_num
from datacleaning)
select * from cte
where row_num>1;

#Delete Unused Columns
alter table datacleaning
	drop column PropertyAddress, 
    drop column SaleDate, 
    drop column OwnerAddress;

select* from datacleaning;




