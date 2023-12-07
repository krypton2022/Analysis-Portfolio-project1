SELECT *
FROM PortFolioProject.dbo.[Housing Data]

SELECT [UniqueID ],ParcelID,OwnerName,TotalValue
FROM PortFolioProject..[Housing Data]

--standardizing the date format 
SELECT SaleDate
FROM PortFolioProject.dbo.[Housing Data]

SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortFolioProject..[Housing Data]

UPDATE [Housing Data]
SET SaleDate=CONVERT(date,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM PortFolioProject..[Housing Data]

--USING ALTER TO ADD ANOTHER COLUMN
ALTER TABLE [Housing Data]
ADD SaleDateConverted date;

UPDATE [Housing Data]
SET SaleDateConverted=CONVERT(date,SaleDate)

--POPULATING THE PROPERTY ADRESS DATA TO FILL WHERE THERE IS NO ADDRESS

SELECT [UniqueID ],ParcelID,PropertyAddress
FROM PortFolioProject..[Housing Data]

SELECT *
FROM PortFolioProject..[Housing Data]
WHERE PropertyAddress is NULL

SELECT a.[UniqueID ],a.PropertyAddress,a.ParcelID,b.[UniqueID ],b.ParcelID,b.PropertyAddress
FROM PortFolioProject..[Housing Data] a
JOIN PortFolioProject..[Housing Data] b
ON a.ParcelID=b.ParcelID AND
a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL
ORDER BY	1,3,4,5

SELECT a.[UniqueID ],a.PropertyAddress,a.ParcelID,b.[UniqueID ],b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortFolioProject..[Housing Data] a
JOIN PortFolioProject..[Housing Data] b
ON a.ParcelID=b.ParcelID AND
a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL
ORDER BY	1,3,4,5

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortFolioProject..[Housing Data] a
JOIN PortFolioProject..[Housing Data] b
ON a.ParcelID=b.ParcelID AND
a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--SEPERATING THE ADDRESS INTO CITY, ADDRESS , STATE--
SELECT PropertyAddress
FROM PortFolioProject..[Housing Data]

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyAddress)-1) AS ADDRESS, 
SUBSTRING(PropertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress)) AS CityAddress
FROM PortFolioProject..[Housing Data]

ALTER TABLE PortFolioProject.dbo.[housing Data]
ADD AddressSpilt NvARchar(255);

UPDATE [Housing Data]
SET AddressSpilt=SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyAddress)-1)

ALTER TABLE PortFolioProject.dbo.[housing Data]
ADD CitySpilt NvARchar(255);

UPDATE [Housing Data]
SET CitySpilt=SUBSTRING(PropertyAddress,CHARINDEX(',',propertyAddress)+1,LEN(propertyAddress))

SELECT *
FROM [Housing Data]

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortFolioProject..[Housing Data]

ALTER TABLE PortFolioProject.dbo.[housing Data]
ADD AddressOwnerSpilt NvARchar(255);

UPDATE [Housing Data]
SET AddressOwnerSpilt= PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortFolioProject.dbo.[housing Data]
ADD OwnerAddressTown NvARchar(255);

UPDATE [Housing Data]
SET OwnerAddressTown=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortFolioProject.dbo.[housing Data]
ADD OwnerAddressCountry NvARchar(255);

UPDATE [Housing Data]
SET OwnerAddressCountry=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM [Housing Data]

--CHANGING SOLDVACANT FROM Y TO "YES" AND N TO "NO"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Housing Data]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN soldAsVacant='y' THEN 'YES'
	 WHEN soldAsVacant='N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM [Housing Data]

UPDATE [Housing Data]
SET SoldAsVacant=CASE WHEN soldAsVacant='y' THEN 'YES'
	 WHEN soldAsVacant='N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

SELECT *
FROM [Housing Data]

---REMOVING DUPLICATE DATA
WITH DuplicateCTE AS(
SELECT *, ROW_NUMBER() OVER (
PARTITION BY		parcelID,
					propertyAddress,
					SaleDate,
					SalePrice,
					LegalReference
					ORDER BY [UniqueID]
					)
					ROW_NUMBER
FROM [Housing Data]
--ORDER BY ParcelID
)
SELECT *
FROM DuplicateCTE
WHERE ROW_NUMBER>1

--DELETING UNUSED COLUMN
 SELECT *
 FROM [Housing Data]

 ALTER TABLE [Housing Data]
 DROP COLUMN PropertyAddress,OwnerAddress,SaleDateConverted,TaxDistrict

 ALTER TABLE [Housing Data]
 DROP COLUMN SaleDate