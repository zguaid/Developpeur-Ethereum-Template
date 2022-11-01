# Explication des TUs réalisés - Projet - Système de vote 2 [Alyra]

*Ce readme donne une vue général sur les TUs réalisés pour le projet - [Système de vote 2](https://github.com/lecascyril/CodesRinkeby/blob/main/voting.sol) pour la certificaition **Développeur Blockchain** de [Alyra](https://alyra.fr/decouvrir-la-formation-developpeur-blockchain-alyra/) réialisés par Ayoub ZGUAID* 

## Démarrage <a id="demarrage"></a>
Les instructions suivantes vous permettrons de lancer les TUs : 

### 1. Cloner le smart contract <a id="clonerSmartContract"></a>

Cloner le smart contract [Voting](https://github.com/lecascyril/CodesRinkeby/blob/main/voting.sol) dans votre dossier contracts dans votre projet que vous appelerez, par exemple, `Voting.sol`.

### 2. Cloner le fichier de test <a id="clonerTestFile"></a>

Cloner le smart contract [Test Voting](https://github.com/zguaid/Developpeur-Ethereum-Template/blob/master/4.%20Truffle%20%26%20CI-CD/TestVoting.js) dans votre dossier Tests dans votre projet que vous appelerez, par exemple, `TestVoting.js`.

### 3. Lancer votre Ganache <a id="startGanache"></a>

Lancer [Ganache](https://trufflesuite.com/ganache/) en précisant la mnémoni si vous le souhaiter 
```javascript
ganache -m "mnémonic"
```

### 4. Compiler le projet <a id="compileProject"></a>

Compiler le projet sur la blockchain (privé ou public) dans notre cas sur Ganache
```javascript
truffle compile
```

### 5. Lancer les TUs <a id="startTUs"></a>

Lancer les TUs en précisant le fichier à lancer. Dans notre cas, on va lancer notre fichier TestVoting.js
```javascript
truffle test .\test\TestVoting.js
```

## Explications des TUs <a id="explications"></a>
J'ai éviter de faire un couverage à 100% des methodes, mais j'ai essayer de faire des scénarios de tests sur les getters, events, requiert et test complete. plusieurs méthodes peuvent avoir les mêmes scénarios de tests.
