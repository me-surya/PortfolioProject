select *
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From  PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.parcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.parcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null



--Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+ 1 , LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+ 1 , LEN(PropertyAddress))



Select *
from PortfolioProject.dbo.NashvilleHousing



Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT * 
from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldasVacant), Count(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
group by SoldasVacant
order by 2



Select SOldASVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END


--Remove Duplicates( Usually don`t delete the data in your dB)
With t1 as ( Select *,
              ROW_NUMBER () OVER ( PARTITION BY ParcelID,
			                                    PropertyAddress,
												SalePrice,
												SaleDate,
												LegalReference
												ORDER BY UniqueID) row_num
			 from PortfolioProject.dbo.NashvilleHousing)
			 --order by ParcelId
--where row_num > 1			 
Select *  
from t1
where row_num > 1
order by PropertyAddress

--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

Select *
from PortfolioProject.dbo.NashvilleHousing
