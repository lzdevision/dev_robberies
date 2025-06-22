# 🚨 Dev_robberys — Sistema de Roubos para Qbox

**Dev_robberies** é um script funcional, leve e altamente adaptável para servidores que utilizam o framework **Qbox (QBCore)**. Ele permite a criação de roubos personalizados diretamente no ambiente do jogo, com suporte a posicionamento visual de objetos, drops customizados, integração com polícia e muito mais.

---

## Funcionalidades

- **Criação de roubos com qualquer objeto (prop)**  
- **Posicionamento visual com preview ao vivo**  
- **Movimentação e alinhamento manual do prop antes de confirmar**  
- **Target com `ox_target` pronto para interação**  
- **Drops configuráveis diretamente no jogo com múltiplos ite ns**  
- **Requisição de item para iniciar o roubo (opcional)**  
- **Chamada de polícia opcional integrada**  
- **Controle de tempo do roubo (em segundos)**  
- **Comando exclusivo para administradores**

---

## Comando

O comando administrativo principal é:
```
/criarroubo 
Config.Command = ""
```

Esse comando abre um menu da ox_lib com as seguintes opções:

- Criar novo roubo
- Visualizar e ajustar o prop
- Escolher drops no formato de linha (item,quantidade)
- Definir tempo, item necessário e se haverá chamada policial

---

## Exemplo de drops:

```
water,5
goldbar,3
sandwich,2
```

Cada linha representa um item e a quantidade que será entregue ao final do roubo.

---

# Dependências Obrigatórias

Abaixo estão as dependências necessárias para que o script funcione corretamente:

|                              Dependências |                                           |
|----------------|----------------------------------------------------------------------|
| `ox_lib`       | [https://overextended.dev/ox_lib](https://overextended.dev/ox_lib)   |
| `ox_target`    | [https://overextended.dev/ox_target](https://overextended.dev/ox_target) |
| `ox_inventory` | [https://overextended.dev/ox_inventory](https://overextended.dev/ox_inventory) |
| `ps-dispatch`  | [https://github.com/Project-Sloth/ps-dispatch](https://github.com/Project-Sloth/ps-dispatch) |


---

## 💻 Banco de Dados

Inclua o conteúdo de `robberies.sql` no seu banco de dados:

```sql
CREATE TABLE `robberies` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`label` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`coords` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`heading` FLOAT NULL DEFAULT NULL,
	`prop` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`propOffset` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`useTarget` TINYINT(1) NULL DEFAULT NULL,
	`cooldown` INT(11) NULL DEFAULT NULL,
	`requiredItem` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`policeCall` TINYINT(1) NULL DEFAULT NULL,
	`anim` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`anim_clip` VARCHAR(64) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`drops` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`anim_dict` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
);
```

---

## Utilidades

- Qbox - Última versão estável (base QBCore)
- ox_lib, ox_target, ox_inventory atualizados
- MySQL/MariaDB

---

## Desenvolvimento

Desenvolvido por [**@lzdevision**](https://github.com/lzdevision), Discord: lzdv_  
❤️ Para suporte ou colaboração, entre em contato via GitHub ou Discord.

## 📜 Licença

Este projeto é licenciado sob os termos da **MIT License**. Você pode usá-lo, modificá-lo e distribuí-lo livremente, desde que mantenha os créditos.

---
