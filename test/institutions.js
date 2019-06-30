const truffleAssert = require('truffle-assertions')

const Issuers = artifacts.require("Issuers")


contract("Instituições", async accounts => {

    let admin = accounts[0]
    let issuer = accounts[1]
    let institution = "0x0300000000000000000000000034000000000000000000000000000000000000"

    it("Admin pode criar instituição.", async () => {
        let instance = await Issuers.new()
        let result = await instance.addInstitution(
            "Go Blockchain",
            institution,
        )
        await truffleAssert.eventEmitted(result, 'logNewInstitution', (ev) => {
            return ev._name == "Go Blockchain" && ev._code == institution
        })
    })

    it("Outros não podem criar instituição.", async () => {
        let instance = await Issuers.new()
        await truffleAssert.fails(
            instance.addInstitution("Go Blockchain", institution, {
                from: issuer
            })
        )
    })

    it("Outros não podem revogar instituição.", async () => {
        let instance = await Issuers.new()
        let result = await instance.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = result.receipt.logs[0].args[0]
        await truffleAssert.fails(
            instance.invalidateInstitution(institutionHash, {
                from: accounts[2]
            })
        )
    })

    it("Admin pode revogar instituição.", async () => {
        let instance = await Issuers.new()
        let result = await instance.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = result.receipt.logs[0].args[0]
        await truffleAssert.passes(
            instance.invalidateInstitution(institutionHash)
        )
    })
})