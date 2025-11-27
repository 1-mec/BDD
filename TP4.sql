-- 2
delimiter $$
create or replace PROCEDURE oui( IN congreside int , IN participantide int)
BEGIN
	DECLARE cnt int;
    DECLARE id int;
    SELECT count(*) into cnt
    from inscription i
    where congreside = i.congresid and participantide = i.participantid;
    if cnt > 0 THEN
    	signal sqlstate '45000'
        set MESSAGE_TEXT = 'erreure lskjdfklj';
	else 
    	insert into inscription (
            congresid , participantid ,dateinscription,etat) 
            values (congreside , participantide , CURRENT_DATE , 'VALidE');
            
        set id = LAST_INSERT_ID() ;
        SELECT id as message ;
    end if;
END $$
Delimiter ;
                
-- petit a

-- petit b
call oui(1,2) 

-- 3a
-- son identifiant, son nom, son prénom) le nombre d'articles qu'il a rédigés

select a.nom , a.prenom , a.personneid , COUNT(r.auteurid)
from auteur a inner join rediger r on r.auteurid = a.personneid
group by a.personneid , a.nom , a.prenom;

-- 3b
-- Écrivez la fonction stockée qui permet d'obtenir le nombre d'articles qu'un auteur a écrits. L'identifiant de l'auteur est passé en paramètre.
delimiter $$
create or replace FUNCTION compteArticle( IdAuteur int )
RETURNS INT
BEGIN
	DECLARE cnt int;
    SELECT count(*) into cnt
    from auteur a
    where IdAuteur = a.personneid ;
return cnt;
END $$
Delimiter ;

-- 3c
-- chaque auteur (son identifiant, son nom, son prénom) le nombre d'articles qu'il a rédigé en utilisant la procédure stockée écrite

select a.personneid , a.nom , a.prenom , compteArticle(a.personneid)
from auteur a
group by a.personneid , a.nom , a.prenom;

-- 4
-- Au niveau de la table « congres », on veut mettre en place un (des) trigger(s) qui ne permette pas d’insérer ou modifier un congrès si sa date du début est inférieur ou égale à sa date de fin (un message d’erreurs devra s’afficher et le traitement sera arrêté)

-- Au niveau de la table « congres », on veut mettre en place un (des) trigger(s) qui ne permette pas d’insérer ou modifier un congrès si sa date du début est inférieur ou égale à sa date de fin (un message d’erreurs devra s’afficher et le traitement sera arrêté)

delimiter $$ 
CREATE or REPLACE TRIGGER verifDate 
after INSERT on congres
for EACH ROW
begin 
	DECLARE temp_date date;
	SELECT c.datedebut , c.datefin into temp_date
    from congres c
    where temp_date >= c.datedebut and temp_date >= c.datefin;
    if not (temp_date >= c.datedebut) or not (temp_date >= c.datefin) THEN
    	signal sqlstate '45000'
        set MESSAGE_TEXT = 'mauvaise date';
	end if;
END $$


CREATE or REPLACE TRIGGER verifDateUpdate
after update on congres
for EACH ROW
begin 
	DECLARE temp_date date;
	SELECT c.datedebut , c.datefin into temp_date
    from congres c
    where temp_date >= c.datedebut and temp_date >= c.datefin;
    if not (temp_date >= c.datedebut) or not (temp_date >= c.datefin) THEN
    	signal sqlstate '45000'
        set MESSAGE_TEXT = 'mauvaise date';
	end if;
DELIMITER ;
-- 5
INSERT into congres ( domaineid,batimentid, nom, datedebut, datefin, prixSejourHT) values (1,10,'GTB','2025-01-31','2025-10-31',90);

DELIMITER
$$
CREATE
OR REPLACE TRIGGER congres_date_insert BEFORE
INSERT
	ON congres FOR EACH ROW
BEGIN
IF NEW.datedebut > NEW.datefin THEN SIGNAL SQLSTATE '45000'
SET
	MESSAGE_TEXT = 'Erreur';
END IF;
END
$$
DELIMITER;
-- ` ;` instead of `;`
-- 4b
DELIMITER
$$
CREATE
OR REPLACE TRIGGER congres_date_update BEFORE
UPDATE
	ON congres FOR EACH ROW
BEGIN
IF NEW.datedebut > NEW.datefin THEN SIGNAL SQLSTATE '45000'
SET
	MESSAGE_TEXT = 'Erreur';
END IF;
END
$$
DELIMITER;

-- 4c 
INSERT into congres ( domaineid,batimentid, nom, datedebut, datefin, prixSejourHT) values (1,10,'ICPR','2025-12-01','2025-07-05',750);

-- 5 
DELIMITER
$$
CREATE
OR REPLACE TRIGGER session_date_insert BEFORE
INSERT
	ON session FOR EACH ROW
BEGIN
DECLARE
v_datedebut DATE;
DECLARE
v_datefin DATE;
DECLARE
CONTINUE HANDLER FOR NOT FOUND
BEGIN
SIGNAL SQLSTATE '45000'
SET
	MESSAGE_TEXT = 'Erreur';
END;
SELECT
	datedebut,
	datefin INTO v_datedebut,
	v_datefin
FROM
	congres
WHERE
	congresid = NEW.congresid;
IF DATE(NEW.datehrsession) NOT BETWEEN v_datedebut AND v_datefin THEN SIGNAL SQLSTATE '45000'
SET
	MESSAGE_TEXT = 'Erreur';
END IF;
END
$$
CREATE
OR REPLACE TRIGGER session_date_update BEFORE
UPDATE
	ON session FOR EACH ROW
BEGIN
DECLARE
v_datedebut DATE;
DECLARE
v_datefin DATE;
DECLARE
CONTINUE HANDLER FOR NOT FOUND
BEGIN
SIGNAL SQLSTATE '45000'
SET
	MESSAGE_TEXT = 'Erreur';
END;
SELECT
	datedebut,
	datefin INTO v_datedebut,
	v_datefin
FROM
	congres
WHERE
	congresid = NEW.congresid;
IF DATE(NEW.datehrsession) NOT BETWEEN v_datedebut AND v_datefin THEN SIGNAL SQLSTATE '45000'
SET
	MESSAGE_TEXT = 'Erreur';
END IF;
END
$$
DELIMITER;

-- 6 a
DELIMITER $$
CREATE OR REPLACE PROCEDURE Opti(
    IN p_Nom VARCHAR(20),
    IN p_Prenom VARCHAR(20), 
    IN p_Email VARCHAR(20),
    IN p_VilleId VARCHAR(20),
    IN p_NoEmployeur VARCHAR(20),
    IN p_Adresse VARCHAR(40)
)
BEGIN
    DECLARE varNom VARCHAR(20);
    DECLARE varAddr VARCHAR(40);
    DECLARE varPrenom VARCHAR(20);
    DECLARE varEmail VARCHAR(20);
    DECLARE varVilleId VARCHAR(20);
    DECLARE varNoEmployeur VARCHAR(20);
    
    -- Assign input parameters to variables (this seems to be your intent)
    SET varNom = p_Nom;
    SET varPrenom = p_Prenom;
    SET varEmail = p_Email;
    SET varVilleId = p_VilleId;
    SET varNoEmployeur = p_NoEmployeur;
    SET varAddr = p_Adresse;
    
    -- Insert using the variables
    INSERT INTO participant (
        personneid,
        villeid, 
        noemployeur, 
        adresse, 
        nom, 
        prenom, 
        email
    ) VALUES (
        LAST_INSERT_ID(),
        varVilleId, 
        varNoEmployeur, 
        varAddr, 
        varNom, 
        varPrenom, 
        varEmail
    );
    INSERT INTO personne (nom, prenom, email) 
    VALUES (p_Nom, p_Prenom, p_Email);
    
END $$
DELIMITER ;

-- 6 b

DELIMITER $$
CREATE OR REPLACE PROCEDURE remplace(
    IN p_Nom VARCHAR(20),
    IN p_Prenom VARCHAR(20), 
    IN p_Email VARCHAR(20)
)
BEGIN
    DECLARE varNom VARCHAR(20);
    DECLARE varPrenom VARCHAR(20);
    DECLARE varEmail VARCHAR(20);
    SET varNom = p_Nom;
    SET varPrenom = p_Prenom;
    SET varEmail = p_Email;
    
    Update participant
    set 
    nom = varNom, 
    prenom = varPrenom, 
    email = varEmail;
    
    UPDATE personne
    set nom = varNom, prenom = varPrenom, email = varEmail;
END $$
DELIMITER ;

-- 6 d 
DELIMITER $$
CREATE OR REPLACE PROCEDURE remplace(
    IN p_PersonneId INT,
    IN p_Nom VARCHAR(20),
    IN p_Prenom VARCHAR(20), 
    IN p_Email VARCHAR(20)
)
BEGIN
    UPDATE personne
    SET nom = p_Nom, prenom = p_Prenom, email = p_Email
    WHERE personneid = p_PersonneId;
    
    UPDATE participant
    SET nom = p_Nom, prenom = p_Prenom, email = p_Email
    WHERE personneid = p_PersonneId;
END $$
DELIMITER ;

-- 7 a
alter TABLE auteur
add COLUMN nbArt int DEFAULT 0,
add CONSTRAINT ch_nbA CHECK (nbArt is not NULL);
-- 7 b 

DELIMITER $$ 
CREATE or REPLACE TRIGGER verif_nbArt_ins
before INSERT on rediger
for each row
begin 
	declare verif int;
    SELECT nbArt into verif
    FROM auteur ;
    set verif = verif + 1;
	UPDATE auteur
    set nbArt = verif;
end $$

CREATE or REPLACE TRIGGER verif_nbArt_del
after DELETE on rediger
for each row
begin 
	declare verif int DEFAULT 0;
    UPDATE auteur
    set nbArt = verif;
end $$
CREATE or REPLACE TRIGGER verif_nbArt_mod
after modify on rediger
for each row
begin 

IF OLD.auteurid != NEW.auteurid THEN
declare verif int;
    SELECT nbArt into verif
    FROM auteur ;
    set verif = verif - 1;
UPDATE
	auteur
SET
	nbArt = verif
WHERE
	personneid = OLD.auteurid;
declare v int;
    SELECT nbArt into v
    FROM auteur ;
    set v = v + 1;
UPDATE
	auteur
SET
	nbArt = v 
WHERE
	personneid = NEW.auteurid;
END IF;
END
$$

delimiter ;


















