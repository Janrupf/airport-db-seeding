    --  Gibt die Tabelle Terminal aus.
SELECT * FROM Terminal;

    --  Gibt die Nummer der verfügbaren ParkPositions pro Terminal aus.
SELECT TerminalID, T.Label as Terminal, COUNT(PP.TerminalID) as AvailablePositions FROM Terminal T, ParkingPosition PP
WHERE T.ID = PP.TerminalID
GROUP BY T.ID;