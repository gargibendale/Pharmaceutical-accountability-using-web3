//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract IssueCred is ERC20, AccessControl {
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE"); //hashes the role string so it's easy to compare.
    bytes32 public constant PHARMACIST_ROLE = keccak256("PHARMACIST_ROLE");
    bytes32 public constant GOVERNMENT_ROLE = keccak256("GOVERNMENT_ROLE");

    struct HealthCareProvider {
        string name;
        string licenseNumber;
        bool isVerified;
    }

    mapping(address => HealthCareProvider) public providers;
    address[] public registeredProviders;
    address[] public verifiedProviders;

    constructor() ERC20("AccountabilityToken", "PHARMA") {
        //grants the admin role to the contract deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        //sets the admin for doctors and pharmacists to be the default admin
        _setRoleAdmin(DOCTOR_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PHARMACIST_ROLE, DEFAULT_ADMIN_ROLE);
        //grants the government role to contract deployer.
        _grantRole(GOVERNMENT_ROLE, msg.sender);

        _mint(msg.sender, (1000 * (10 ** decimals()))); //give the admin thousands of tokens for later use
    }

    function registerProvider(
        address providerAddress,
        string memory name,
        string memory licenseNumber,
        bytes32 role
    ) public onlyRole(GOVERNMENT_ROLE) {
        //check is a valid role has been input
        require(
            role == DOCTOR_ROLE || role == PHARMACIST_ROLE,
            "Invalid role entered"
        );
        providers[providerAddress] = HealthCareProvider(
            name,
            licenseNumber,
            false
        ); //add the provider to the list of healthcare providers
        registeredProviders.push(providerAddress);
    }

    //view the number of providers currently registered
    function getRegisteredProviders() public view returns (address[] memory) {
        return registeredProviders;
    }
    function getVerifiedProviders() public view returns (address[] memory) {
        return verifiedProviders;
    }

    //verify a provider; only the government can do this.
    function verifyProvider(
        address providerAddress,
        bytes32 role
    ) public onlyRole(GOVERNMENT_ROLE) {
        providers[providerAddress].isVerified = true;
        _grantRole(role, providerAddress); //grant the requested role to the provider
        verifiedProviders.push(providerAddress);
    }

    //check if a provider if verified.
    function isProviderVerified(
        address providerAddress
    ) public view returns (bool) {
        return providers[providerAddress].isVerified;
    }

    //incetivize doctors and pharmacists when they prescribe and dispense medication respectively
    // function rewardDoctor(
    //     address doctor,
    //     uint256 amount
    // ) public onlyRole(GOVERNMENT_ROLE) {
    //     require(hasRole(DOCTOR_ROLE, doctor), "Address is not a doctor");
    //     _mint(doctor, amount); // Mint tokens to the doctor
    // }
    // function rewardPharmacist(
    //     address pharmacist,
    //     uint256 amount
    // ) public onlyRole(GOVERNMENT_ROLE) {
    //     require(
    //         hasRole(PHARMACIST_ROLE, pharmacist),
    //         "Address is not a pharmacist"
    //     );
    //     _mint(pharmacist, amount); // Mint tokens to the doctor
    // }
}
