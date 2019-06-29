const truffleAssert = require('truffle-assertions')

const Issuers = artifacts.require("Issuers")

contract("Emissores", async accounts => {

    let issuer = accounts[1]
    let institution = "0x0300000000000000000000000034000000000000000000000000000000000000"

    it("Admin pode dar acesso a um emissor (issuer)", async () => {
        let instance = await Issuers.new()
        let result = await instance.addIssuer(
            issuer,
            institution,
        )
        await truffleAssert.eventEmitted(result, 'logNewIssuer', (ev) => {
            return ev._address == issuer && ev._institution == institution
        })
    })

    it("Outros não podem conceder acesso de issuer", async () => {
        let instance = await Issuers.new()
        truffleAssert.fails(
            instance.addIssuer(
                issuer,
                institution, {
                    from: issuer
                }
            )
        )
        truffleAssert.fails(
            instance.addIssuer(
                issuer,
                institution, {
                    from: accounts[5]
                }
            )
        )
    })

    it("Outros não podem revogar acesso de um emissor (issuer)", async () => {
        let instance = await Issuers.new()
        await truffleAssert.passes(
            instance.addIssuer(
                issuer,
                institution,
            )
        )
        await truffleAssert.reverts(
            instance.revokeIssuer(
                issuer,
                institution, {
                    from: issuer
                }
            )
        )
        await truffleAssert.reverts(
            instance.revokeIssuer(
                issuer,
                institution, {
                    from: accounts[5]
                }
            )
        )
    })

    it("Admin pode revogar acesso de um emissor (issuer)", async () => {
        let instance = await Issuers.new()
        await truffleAssert.passes(
            await instance.addIssuer(
                issuer,
                institution,
            )
        )
        await truffleAssert.passes(
            await instance.revokeIssuer(
                issuer,
                institution,
            )
        )
        let hasRole = await instance.hasRole(
            issuer,
            institution,
        )
        assert.equal(hasRole, false)
    })
})