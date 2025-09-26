
///SPDX-License-Identifier: MIT 
pragma solidity 0.8.26;

contract KipuBank {
    uint256 immutable i_umbral;
    uint256 s_bankCap;
    uint256 s_totAcumulado = 0;
    uint256 s_nroDepositos = 0;
    uint256 s_nroRetiros = 0;

    mapping(address _usuario => uint256 saldo) s_saldos;

    // EVENTS

    /// @notice Evento emitido cuando un usuario realiza un depósito.
    /// @param usuario Dirección del usuario que deposita.
    /// @param valor Monto de Ether depositado.  
    event KipuBank_Deposito(address usuario, uint256 valor);

    /// @notice Evento emitido cuando un usuario realiza un retiro.
    /// @param usuario Dirección del usuario que retira.
    /// @param valor Monto de Ether retirado.
    event KipuBank_Retiro(address usuario, uint256 valor);

    // ERRORES

    /// @notice Se lanza cuando el valor ingresado es cero.
    error KipuBank_ValorCero();
    
    /// @notice Se lanza cuando el usuario intenta retirar más de lo que tiene.
    /// @param saldoSolicitado Monto solicitado que excede el saldo disponible. 
    error KipuBank_SaldoInsuficiente(uint256 saldoSolicitado);

    /// @notice Se lanza cuando el retiro supera el umbral permitido.
    /// @param saldoSolicitado Monto solicitado que excede el umbral.
    error KipuBank_SaldoSuperaLimite(uint256 saldoSolicitado);

    /// @notice Se lanza cuando el depósito supera la capacidad total del banco.
    /// @param saldoSolicitado Monto solicitado.
    /// @param exceso Diferencia entre el depósito y la capacidad restante. 
    error KipuBank_SinCapacidad(uint256 saldoSolicitado, uint256 exceso);

    /// @notice Se lanza cuando la transferencia de Ether falla.
    /// @param usuario Dirección del destinatario.
    /// @param cantidad Monto que se intentó transferir.
    error KipuBank_TransferenciaFallida(address usuario, uint256 cantidad);

    // MODIFICADORES

    /// @dev Verifica que el valor ingresado no sea cero.
    /// @param valor Monto que se desea validar.
    /// @custom:error KipuBank_ValorCero Se lanza si el valor es igual a cero.
    modifier validar(uint256 valor) {
        if (valor == 0) revert KipuBank_ValorCero(); // Lanzo error
        _; // Esto dice que quiere que aca se pegue el resto del codigo de la funcion
    }

    /// @dev Verifica que el banco tenga capacidad suficiente para aceptar el depósito.
    /// @param valor Monto que se desea depositar.
    /// @custom:error KipuBank_SinCapacidad Se lanza si el depósito excede la capacidad máxima del banco.
    modifier validarMaximoBanco(uint256 valor) {
        if (s_totAcumulado + valor > s_bankCap) revert KipuBank_SinCapacidad(valor, s_totAcumulado + valor - s_bankCap);
        _;
    }

    // CONSTRUCTOR

    /// @notice Inicializa el contrato con un umbral máximo de retiro y una capacidad total del banco.
    /// @param _umbral Límite máximo permitido para retiros individuales.
    /// @param _bankCap Capacidad total de Ether que puede almacenar el banco.
    /// @dev Aplica validaciones para asegurar que los valores iniciales no sean cero.
    constructor(uint256 _umbral, uint256 _bankCap) validar(_umbral) validar(_bankCap) {
        i_umbral = _umbral;
        s_bankCap = _bankCap;
    }

    // FUNCIONES

    /// @notice Consulta el saldo disponible del usuario que llama.
    /// @return saldo El monto de Ether disponible para retiro.
    function getFondos() public view returns (uint256 saldo) {
        return s_saldos[msg.sender];
    }

    /// @notice Permite depositar Ether en el banco.
    /// @dev Valida que el valor no sea cero y que no se exceda la capacidad máxima del banco.
    /// @custom:modifiers validar, validarMaximoBanco
    function depositar() external payable validar(msg.value) validarMaximoBanco(msg.value) {
        s_saldos[msg.sender] += msg.value;
        s_totAcumulado += msg.value;
        s_nroDepositos++;
        emit KipuBank_Deposito(msg.sender, msg.value);
    }

    /// @notice Permite retirar Ether del banco si se cumplen las condiciones.
    /// @param _cantidad Monto de Ether que se desea retirar.
    /// @dev Verifica que el monto no supere el umbral y que el usuario tenga saldo suficiente.
    /// @custom:errors KipuBank_SaldoSuperaLimite, KipuBank_SaldoInsuficiente
    function retirar(uint256 _cantidad) external {
        if (_cantidad > i_umbral) revert KipuBank_SaldoSuperaLimite(_cantidad);
        if (s_saldos[msg.sender] < _cantidad) revert KipuBank_SaldoInsuficiente(_cantidad);

        _transferirFondos(msg.sender, _cantidad);

        s_totAcumulado -= _cantidad;
        s_saldos[msg.sender] -= _cantidad;
        s_nroRetiros++;
        emit KipuBank_Retiro(msg.sender, _cantidad);
    }

    /// @notice Transfiere Ether al usuario especificado.
    /// @param _usuario Dirección del destinatario.
    /// @param _cantidad Monto de Ether a transferir.
    /// @dev Utiliza low-level call para enviar Ether. Lanza error si la transferencia falla.
    /// @custom:error KipuBank_TransferenciaFallida
    function _transferirFondos(address _usuario, uint256 _cantidad) private {
        (bool ok, ) = payable(_usuario).call{value: _cantidad}("");
        if (!ok) revert KipuBank_TransferenciaFallida(_usuario, _cantidad);
    }


}