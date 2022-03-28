import {
    Field,
    PrivateKey,
    PublicKey,
    SmartContract,
    state,
    State,
    method,
    UInt64,
    Mina,
    Party,
    isReady,
    shutdown,
} from 'snarkyjs';

// Statistics of a character
// Skill points must be spent on either attack or defense power.
class CharStat extends SmartContract {
    @state(Field) sp: State<Field>; // spendable skill points
    @state(Field) att: State<Field>; // attack power
    @state(Field) def: State<Field>; // defense power

    constructor(initialBalance: UInt64, address: PublicKey, init_sp: Field, init_att: Field, init_def: Field) {
        super(address);
        this.balance.addInPlace(initialBalance);
        init_sp.assertEquals(init_att.add(init_def));
        this.sp = State.init(init_sp);
        this.att = State.init(init_att);
        this.def = State.init(init_def);
    }

    // Update character statistics
    @method async update(new_sp: Field, new_att: Field, new_def: Field) {
        new_sp.assertEquals(new_att.add(new_def));
        this.sp.set(new_sp);
        this.att.set(new_att);
        this.def.set(new_def);
    }
}

// Unit tests
export async function run() {
    await isReady;

    const Local = Mina.LocalBlockchain();
    Mina.setActiveInstance(Local);
    const account1 = Local.testAccounts[0].privateKey;
    const account2 = Local.testAccounts[1].privateKey;

    const snappPrivkey = PrivateKey.random();
    const snappPubkey = snappPrivkey.toPublicKey();

    // Initial parameters
    let snappInstance: CharStat;
    const initSP = new Field(100);
    const initATT = new Field(50);
    const initDEF = new Field(50);

    // Deploys the snapp
    await Mina.transaction(account1, async () => {
        // account2 sends 1000000000 to the new snapp account
        const amount = UInt64.fromNumber(1000000000);
        const p = await Party.createSigned(account2);
        p.balance.subInPlace(amount);

        snappInstance = new CharStat(amount, snappPubkey, initSP, initATT, initDEF);
    })
        .send()
        .wait();

    // Print initial state
    const b = await Mina.getAccount(snappPubkey);
    console.log('Initial state values: SP -', b.snapp.appState[0].toString(), ', ATT -', b.snapp.appState[1].toString(), ', DEF -', b.snapp.appState[2].toString());

    // Valid snapp update
    await Mina.transaction(account1, async () => {
        // sp: 200 = att: 170 + def: 30
        await snappInstance.update(new Field(200), new Field(170), new Field(30));
    })
        .send()
        .wait();
        console.log('Update state: SP - 200, ATT - 170, DEF - 30')

    // Bad snapp update, underspend SP
    await Mina.transaction(account1, async () => {
        // sp: 1300 > att: 10 + def: 10
        await snappInstance.update(new Field(1300), new Field(10), new Field(10));
    })
        .send()
        .wait()
        .catch((e) => console.log('Failure test passes: SP underspent'));
    
    // Bad snapp update, overspend SP
    await Mina.transaction(account1, async () => {
        // sp: 50 > att: 40 + def: 30
        await snappInstance.update(new Field(50), new Field(40), new Field(30));
    })
        .send()
        .wait()
        .catch((e) => console.log('Failure test passes: SP overspent'));

    // Print final state
    const a = await Mina.getAccount(snappPubkey);
    console.log('Final state values: SP -', a.snapp.appState[0].toString(), ', ATT -', a.snapp.appState[1].toString(), ', DEF -', a.snapp.appState[2].toString());
}

run();
shutdown();