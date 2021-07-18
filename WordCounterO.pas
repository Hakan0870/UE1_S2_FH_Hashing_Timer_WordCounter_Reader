PROGRAM WordCounterO;

USES
    Crt, Timer, WordReader;

CONST
    HashTableSize = 120000;

TYPE
    Element = RECORD
        value: STRING;
        next: ^Element;
        counter: INTEGER;
    END;

    Hash = 1..HashTableSize;
    HashTable = ARRAY[Hash] OF ^Element;


FUNCTION ComputeHash(value: STRING): Hash;
    BEGIN
        IF (Length(value) = 0) THEN
            ComputeHash := 1
        ELSE
            ComputeHash := (ORD(value[1]) MOD HashTableSize) + 1; 
    END; 


PROCEDURE InitHashTable(VAR ht: HashTable);
    VAR
        i: Hash;
    BEGIN
        FOR i := LOW(ht) TO HIGH(ht) DO BEGIN
            ht[i] := NIL;
        END;
    END; 


PROCEDURE DisposeHashTable(VAR ht: HashTable);
    VAR
        i: Hash;
        n: ^Element;
    BEGIN
        FOR i := LOW(ht) TO HIGH(ht) DO BEGIN
            WHILE (ht[i] <> NIL) DO BEGIN
                n := ht[i]^.next;
                Dispose(ht[i]);
                ht[i] := n;
            END;
        END; 
    END;



PROCEDURE AddToHashTable(VAR ht: HashTable; value: STRING);
    VAR
        i: Hash;
        e: ^Element;
        n: ^Element;
    BEGIN  
        i := ComputeHash(value);
        n := ht[i];
        IF n = NIL THEN BEGIN
            New(e);
            e^.value := value;
            e^.counter := 1;
            e^.next := ht[i];
            ht[i] := e;        
        END ELSE BEGIN
            IF n^.value = value THEN
                INC(n^.counter)
            ELSE BEGIN 
                WHILE (n <> NIL) AND (n^.value <> value) DO
                    n := n^.next;
                IF n = NIL THEN BEGIN
                    New(e);
                    e^.value := value;
                    e^.counter := 1;
                    e^.next := ht[i];
                    ht[i] := e;                    
                END ELSE IF n^.value = value THEN
                    INC(n^.counter)           
            END;
        END;       
    END; 


PROCEDURE DisposeWordsOnce(VAR ht: HashTable);
    VAR
        i: Hash;
        n: ^Element;
        m: ^Element;
    BEGIN
        FOR i := LOW(Hash) TO HIGH(Hash) DO BEGIN
            n := ht[i];
            m := NIL;
            WHILE n  <> NIL DO BEGIN
                IF (n^.counter = 1) AND (m = NIL) THEN BEGIN
                    ht[i] := n^.next;
                    Dispose(n);
                    n := ht[i];
                END ELSE IF (n^.counter <> 1) AND (m = NIL) THEN BEGIN
                    m := n;
                    n := n^.next;
                END ELSE IF (n^.counter = 1) AND (m <> NIL) THEN BEGIN
                    m^.next := n^.next;
                    Dispose(n);
                    n := m^.next;
                END ELSE BEGIN
                    n := n^.next;
                    m := m^.next;
                END;
            END;
        END;
    END; 


PROCEDURE WordsMoreThanOnce(ht: HashTable);
    VAR
        i: Hash;
        count: LONGINT;
        n: ^Element;
    BEGIN
        count := 0;
        FOR i := LOW(Hash) TO HIGH(Hash) DO BEGIN
            n := ht[i];
            WHILE (n <> NIL) DO BEGIN
                count := count + 1;
                n := n^.next;
            END; 
        END; 
        WriteLn('Number of words more than once: ', count); 
    END;

PROCEDURE MostCommonWord(ht : HashTable);
    VAR
        i: Hash;
        n: ^Element;
        mostWordCount: INTEGER;
        mostWord: STRING;
    BEGIN
        mostWordCount := 0;
        mostWord := '';
        FOR i := LOW(Hash) TO HIGH(Hash) DO BEGIN
            n := ht[i];
            WHILE (n <> NIL) DO BEGIN
                IF n^.counter > mostWordCount THEN BEGIN
                    mostWord := n^.value;
                    mostWordCount := n^.counter;
                END;
                n := n^.next;
            END; 
        END; 
        WriteLn('Most common word: ', mostWord,' ', mostWordCount); 
    END;



VAR
    w: Word;
    n: LONGINT;
    ht: HashTable;

BEGIN 

    InitHashTable(ht);
    WriteLn;

    WriteLn('WordCounter:');
    OpenFile('Kafka.txt', toLower);
    StartTimer;
    n := 0;
    ReadWord(w);
    WHILE w <> '' DO BEGIN
        n := n + 1;
        AddToHashTable(ht, w);
        (*insert word in data structure and count its occurence*)
        ReadWord(w);
    END; 
    StopTimer;
    CloseFile;
    WriteLn('number of words: ', n);
    WriteLn('elapsed time:    ', ElapsedTime);

    MostCommonWord(ht);

    DisposeWordsOnce(ht);
    WordsMoreThanOnce(ht);
    
    DisposeHashTable(ht);
    
END. 