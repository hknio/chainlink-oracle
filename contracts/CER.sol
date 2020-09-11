pragma solidity >= 0.6.6;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.6/vendor/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CER is ChainlinkClient, Ownable {
    uint256 constant private ORACLE_PAYMENT = 1 * LINK;
    address ORACLE_CONTRACT_ADDRESS;
    string REQUEST_VALIDATION_JOB_ID = "0171804950a447eea3c64ce1419552c4";
    string REQUEST_CERTIFICATE_CERTIFICATION_JOB_ID = "bafb4e874c3e4f3399988c975fc63fd1";
    string REQUEST_DEFI_AUDIT_JOB_ID = "9a9d94a83fc8481490592437e2ccb310";
    string REQUEST_DEFI_LAST_AUDIT_DATE_JOB_ID = "1da693eec5624f77b7c890dcfb9f4637";

    // TODO: remove before prod deployment
    bool public REQUEST_CERTIFICATE_VALIDATION;
    int256 public REQUEST_CERTIFICATE_CERTIFICATION;
    bool public REQUEST_DEFI_VALIDATION;
    bytes32 public REQUEST_DEFI_AUDIT;
    int256 public REQUEST_DEFI_LAST_AUDIT_DATE;

    event RequestCertificateValidationFulfilled(
        bytes32 indexed requestId,
        bool indexed valid
    );

    event RequestCertificateCertificationFulfilled(
        bytes32 indexed requestId,
        int256 indexed certification
    );

    event RequestDefiValidationFulfilled(
        bytes32 indexed requestId,
        bool indexed valid
    );

    event RequestDefiAuditFulfilled(
        bytes32 indexed requestId,
        bytes32 indexed audit
    );

    event RequestDefiLastAuditDateFulfilled(
        bytes32 indexed requestId,
        int256 indexed lastAuditDate
    );

    constructor(address _link, address _oracle) public Ownable() {
        ORACLE_CONTRACT_ADDRESS = _oracle;
        setChainlinkToken(_link);
    }

    function updateJobIds(
        string memory _validationJobId,
        string memory _certificateCertificationJobId,
        string memory _defiLastAuditDateJobId,
        string memory _defiAuditJobId
    )
    public
    {
        REQUEST_VALIDATION_JOB_ID = _validationJobId;
        REQUEST_CERTIFICATE_CERTIFICATION_JOB_ID = _certificateCertificationJobId;
        REQUEST_DEFI_AUDIT_JOB_ID = _defiAuditJobId;
        REQUEST_DEFI_LAST_AUDIT_DATE_JOB_ID = _defiLastAuditDateJobId;
    }

    function requestCertificateValidation(string memory _exchange)
        public
    {
        IERC20(chainlinkTokenAddress()).transferFrom(msg.sender, address(this), ORACLE_PAYMENT);
        bytes memory urlBytes;
        urlBytes = abi.encodePacked("https://cer.live/historical/certificates/validate?exchange=");
        urlBytes = abi.encodePacked(urlBytes, _exchange);

        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(REQUEST_VALIDATION_JOB_ID),
            address(this),
            this.fulfillCertificateValidation.selector
        );
        req.add("get", string(urlBytes));
        sendChainlinkRequestTo(ORACLE_CONTRACT_ADDRESS, req, ORACLE_PAYMENT);
    }

    function requestCertificateCertification(string memory _exchange)
        public
    {
        IERC20(chainlinkTokenAddress()).transferFrom(msg.sender, address(this), ORACLE_PAYMENT);
        bytes memory urlBytes;
        urlBytes = abi.encodePacked("https://cer.live/historical/certificates?exchange=");
        urlBytes = abi.encodePacked(urlBytes, _exchange);

        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(REQUEST_CERTIFICATE_CERTIFICATION_JOB_ID),
            address(this),
            this.fulfillCertificateCertification.selector
        );

        req.add("get", string(urlBytes));
        sendChainlinkRequestTo(ORACLE_CONTRACT_ADDRESS, req, ORACLE_PAYMENT);
    }

    function requestDefiValidation(string memory _projectName)
        public
    {
        IERC20(chainlinkTokenAddress()).transferFrom(msg.sender, address(this), ORACLE_PAYMENT);
        bytes memory urlBytes;
        urlBytes = abi.encodePacked("https://cer.live/historical/defi/validate?projectName=");
        urlBytes = abi.encodePacked(urlBytes, _projectName);

        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(REQUEST_VALIDATION_JOB_ID),
            address(this),
            this.fulfillDefiValidation.selector
        );
        req.add("get", string(urlBytes));
        sendChainlinkRequestTo(ORACLE_CONTRACT_ADDRESS, req, ORACLE_PAYMENT);
    }

    function requestDefiAudit(string memory _projectName)
        public
    {
         IERC20(chainlinkTokenAddress()).transferFrom(msg.sender, address(this), ORACLE_PAYMENT);
        bytes memory urlBytes;
        urlBytes = abi.encodePacked("https://cer.live/historical/defi?projectName=");
        urlBytes = abi.encodePacked(urlBytes, _projectName);

        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(REQUEST_DEFI_AUDIT_JOB_ID),
            address(this),
            this.fulfillDefiAudit.selector
        );
        req.add("get", string(urlBytes));
        sendChainlinkRequestTo(ORACLE_CONTRACT_ADDRESS, req, ORACLE_PAYMENT);
    }

    function requestDefiLastAuditDate(string memory _projectName)
        public
    {
         IERC20(chainlinkTokenAddress()).transferFrom(msg.sender, address(this), ORACLE_PAYMENT);
        bytes memory urlBytes;
        urlBytes = abi.encodePacked("https://cer.live/historical/defi?projectName=");
        urlBytes = abi.encodePacked(urlBytes, _projectName);

        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(REQUEST_DEFI_LAST_AUDIT_DATE_JOB_ID),
            address(this),
            this.fulfillDefiLastAuditDate.selector
        );
        req.add("get", string(urlBytes));
        sendChainlinkRequestTo(ORACLE_CONTRACT_ADDRESS, req, ORACLE_PAYMENT);
    }

    function fulfillCertificateValidation(bytes32 _requestId, bool _valid)
        public
    recordChainlinkFulfillment(_requestId)
    {
        emit RequestCertificateValidationFulfilled(_requestId, _valid);
        REQUEST_CERTIFICATE_VALIDATION = _valid;
    }

    function fulfillCertificateCertification(bytes32 _requestId, int256 _certification)
        public
    recordChainlinkFulfillment(_requestId)
    {
        emit RequestCertificateCertificationFulfilled(_requestId, _certification);
        REQUEST_CERTIFICATE_CERTIFICATION = _certification;
    }

    function fulfillDefiValidation(bytes32 _requestId, bool _valid)
        public
    recordChainlinkFulfillment(_requestId)
    {
        emit RequestDefiValidationFulfilled(_requestId, _valid);
        REQUEST_DEFI_VALIDATION = _valid;
    }

    function fulfillDefiAudit(bytes32 _requestId, bytes32 _audit)
        public
    recordChainlinkFulfillment(_requestId)
    {
        emit RequestDefiAuditFulfilled(_requestId, _audit);
        REQUEST_DEFI_AUDIT = _audit;
    }

    function fulfillDefiLastAuditDate(bytes32 _requestId, int256 _lastAuditDate)
        public
    recordChainlinkFulfillment(_requestId)
    {
        emit RequestDefiLastAuditDateFulfilled(_requestId, _lastAuditDate);
        REQUEST_DEFI_LAST_AUDIT_DATE = _lastAuditDate;
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    )
        public
    {
        cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {// solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}