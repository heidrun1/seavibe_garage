CREATE TABLE `owned_vehicles` (
  `id` int(11) NOT NULL,
  `owner` varchar(46) DEFAULT NULL,
  `vehicle` longtext CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `vehicleData` longtext NOT NULL DEFAULT '{"engine":1000.0,"fuel":100,"body":100}',
  `vehicleid` int(11) DEFAULT NULL,
  `owner_type` int(11) NOT NULL DEFAULT 1,
  `state` tinyint(1) DEFAULT 0,
  `plate` varchar(12) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `type` varchar(50) DEFAULT 'car',
  `scrap` int(11) DEFAULT NULL,
  `society` varchar(50) DEFAULT 'unemployed',
  `fuel` int(11) DEFAULT 0,
  `glovebox` longtext DEFAULT NULL,
  `trunk` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci;

ALTER TABLE `owned_vehicles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `owner` (`owner`),
  ADD KEY `plate` (`plate`),
  ADD KEY `owner_type` (`owner_type`),
  ADD KEY `state` (`state`);

ALTER TABLE `owned_vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;
COMMIT;
