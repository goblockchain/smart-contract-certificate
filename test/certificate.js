const truffleAssert = require('truffle-assertions')

const Issuers = artifacts.require("Issuers")
const CertificatePrint = artifacts.require("CertificatePrint")
const Token = artifacts.require("TokenMock")

contract("Certificados", async accounts => {

    let admin = accounts[0]
    let issuer = accounts[1]
    let institution = "0x0300000000000000000000000034000000000000000000000000000000000000"
    let institution2 = "0x0300000000000000000000000034000000000000000000000000000000000001"
    let wallet = accounts[3]
    let price = "100000000000000000"

    let name = "Fabio Hildebrand"
    let email = "fabiohildebrand@gmail.com"
    let course = "GBC - Solidity"
    let dates = "1 de fevereiro de 2018"
    let hours = 16
    let instructorName = "Henrique Leite"

    it("Issuer pode imprimir certificado da sua instituição", async () => {
        let issuers = await Issuers.new()
        let token = await Token.new()
        let instance = await CertificatePrint.new(price, token.address, issuers.address, wallet)

        let inst = await issuers.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = inst.receipt.logs[0].args[0]

        await issuers.addIssuer(
            issuer,
            institutionHash
        )

        await token.faucet({
            from: issuer
        })
        await token.approve(instance.address, price, {
            from: issuer
        })
        let result = await instance.printCertificate(
            name,
            email,
            institutionHash,
            course,
            dates,
            hours,
            instructorName,
            "0x0", {
                from: issuer
            }
        )
        await truffleAssert.eventEmitted(result, 'logPrintedCertificate', (ev) => {
            return ev._name == name && ev._email == email && ev._institution == institutionHash && ev._course == course && ev._dates == dates
        })
    })

    it("Issuer não pode imprimir certificado de instituição inexistente", async () => {
        let issuers = await Issuers.new()
        let token = await Token.new()
        let instance = await CertificatePrint.new(price, token.address, issuers.address, wallet)

        await issuers.addInstitution(
            "Go Blockchain",
            institution,
        )

        await issuers.addIssuer(
            issuer,
            institution
        )

        await token.faucet({
            from: issuer
        })
        await token.approve(instance.address, price, {
            from: issuer
        })
        await truffleAssert.reverts(
            instance.printCertificate(
                name,
                email,
                institution2,
                course,
                dates,
                hours,
                instructorName,
                "0x0", {
                    from: issuer
                }
            )
        )
    })

    it("Issuer não pode imprimir certificado de instituição inválida", async () => {
        let issuers = await Issuers.new()
        let token = await Token.new()
        let instance = await CertificatePrint.new(price, token.address, issuers.address, wallet)

        let result = await issuers.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = result.receipt.logs[0].args[0]

        await issuers.addIssuer(
            issuer,
            institutionHash
        )

        await issuers.invalidateInstitution(institutionHash)

        await token.faucet({
            from: issuer
        })
        await token.approve(instance.address, price, {
            from: issuer
        })
        await truffleAssert.reverts(
            instance.printCertificate(
                name,
                email,
                institutionHash,
                course,
                dates,
                hours,
                instructorName,
                "0x0", {
                    from: issuer
                }
            )
        )
    })

    it("Issuer não pode imprimir certificado sem pagar", async () => {
        let issuers = await Issuers.new()
        let token = await Token.new()
        let instance = await CertificatePrint.new(price, token.address, issuers.address, wallet)

        let result = await issuers.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = result.receipt.logs[0].args[0]

        await issuers.addIssuer(
            issuer,
            institutionHash
        )

        await truffleAssert.reverts(
            instance.printCertificate(
                name,
                email,
                institutionHash,
                course,
                dates,
                hours,
                instructorName,
                "0x0", {
                    from: issuer
                }
            )
        )
    })

    it("Issuer pode revogar certificado da sua instituição", async () => {
        let issuers = await Issuers.new()
        let token = await Token.new()
        let instance = await CertificatePrint.new(price, token.address, issuers.address, wallet)

        let inst = await issuers.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = inst.receipt.logs[0].args[0]

        await issuers.addIssuer(
            issuer,
            institutionHash
        )

        await token.faucet({
            from: issuer
        })
        await token.approve(instance.address, (Number(price) * 2).toString(), {
            from: issuer
        })
        let result = await instance.printCertificate(
            name,
            email,
            institutionHash,
            course,
            dates,
            hours,
            instructorName,
            "0x0", {
                from: issuer
            }
        )
        let certificateAddress = result.receipt.logs[0].args[0]
        await instance.invalidateCertificate(
            certificateAddress, {
                from: issuer
            }
        )

        const isValid = await instance.certificates(certificateAddress)
        assert.equal(isValid.valid, false)
    })

    it("Outros não podem revogar certificado", async () => {
        let issuers = await Issuers.new()
        let token = await Token.new()
        let instance = await CertificatePrint.new(price, token.address, issuers.address, wallet)

        let inst = await issuers.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = inst.receipt.logs[0].args[0]

        await issuers.addIssuer(
            issuer,
            institutionHash
        )

        await token.faucet({
            from: issuer
        })
        await token.approve(instance.address, (Number(price) * 2).toString(), {
            from: issuer
        })
        let result = await instance.printCertificate(
            name,
            email,
            institutionHash,
            course,
            dates,
            hours,
            instructorName,
            "0x0", {
                from: issuer
            }
        )
        let certificateAddress = result.receipt.logs[0].args[0]
        await truffleAssert.reverts(
            instance.invalidateCertificate(
                certificateAddress, {
                    from: admin
                }
            )
        )
        await truffleAssert.reverts(
            instance.invalidateCertificate(
                certificateAddress, {
                    from: wallet
                }
            )
        )
        await truffleAssert.reverts(
            instance.invalidateCertificate(
                certificateAddress, {
                    from: accounts[8]
                }
            )
        )

        const isValid = await instance.certificates(certificateAddress)
        assert.equal(isValid.valid, true)
    })

    it("Issuer não pode revogar sem pagar", async () => {
        let issuers = await Issuers.new()
        let token = await Token.new()
        let instance = await CertificatePrint.new(price, token.address, issuers.address, wallet)

        let inst = await issuers.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = inst.receipt.logs[0].args[0]

        await issuers.addIssuer(
            issuer,
            institutionHash
        )

        await token.faucet({
            from: issuer
        })
        await token.approve(instance.address, (Number(price) * 2).toString(), {
            from: issuer
        })
        let result = await instance.printCertificate(
            name,
            email,
            institutionHash,
            course,
            dates,
            hours,
            instructorName,
            "0x0", {
                from: issuer
            }
        )
        let certificateAddress = result.receipt.logs[0].args[0]
        await token.approve(instance.address, "0", {
            from: issuer
        })
        await truffleAssert.reverts(
            instance.invalidateCertificate(
                certificateAddress, {
                    from: issuer
                }
            )
        )

        const isValid = await instance.certificates(certificateAddress)
        assert.equal(isValid.valid, true)
    })
    it("Cobrando o preço certo", async () => {
        let issuers = await Issuers.new()
        let token = await Token.new()
        let instance = await CertificatePrint.new(price, token.address, issuers.address, wallet)

        let inst = await issuers.addInstitution(
            "Go Blockchain",
            institution,
        )
        let institutionHash = inst.receipt.logs[0].args[0]

        await issuers.addIssuer(
            issuer,
            institutionHash
        )

        await token.faucet({
            from: issuer
        })
        await token.approve(instance.address, (Number(price) * 2).toString(), {
            from: issuer
        })
        await instance.printCertificate(
            name,
            email,
            institutionHash,
            course,
            dates,
            hours,
            instructorName,
            "0x0", {
                from: issuer
            }
        )
        const balance = await token.balanceOf(wallet)
        assert.equal(balance.toString(), price)
    })
})